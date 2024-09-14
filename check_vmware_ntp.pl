#!/usr/bin/perl -w

# nagios: -epn
# --
# check_vmware_ntp - Check NTP Time offset
# Copyright (C) 2017 noris network AG, http://www.noris.net/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

# Erweiterungen und Anpassungen am 19.02.2021 und 13.09.2024
# Torsten Bunde (github@torstenbunde.de)

# BEGIN Anpassung 20240913
# Anpassung aufgrund von SSL-Problemen/Fehlermeldungen: "Server version unavailable at ..."
# Quelle: https://www.claudiokuenzler.com/blog/1116/monitoring-plugin-check_vmware_snapshots-perl-error-server-version-unavailable
BEGIN {
  $ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
  eval {
    # required for new IO::Socket::SSL versions
    require IO::Socket::SSL;
    IO::Socket::SSL->import();
    IO::Socket::SSL::set_ctx_defaults( SSL_verify_mode => 0 );
  };
};
# END Anpassungen 20240913

$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

use strict;
use warnings;

use VMware::VICredStore;
use VMware::VIRuntime;
use VMware::VILib;
use VMware::VIExt;

use Date::Parse;
use Time::Local;

use Getopt::Long qw(:config no_ignore_case);

######

GetOptions(
  'H|hostname=s' => \my $Hostname,
  'u|username=s' => \my $Username,
  'p|password=s' => \my $Password,
	'w|warning=s'  => \my $Warning,
	'c|critical=s' => \my $Critical,
  'h|help'       => sub { exec perldoc => -F => $0 or die "Cannot execute perldoc: $!\n"; },
) or Error("$0: Error in command line arguments\n");

sub Error {
  print "$0: " . $_[0] . "\n";
  exit 2;
}
Error('Option --hostname needed!') unless $Hostname;
Error('Option --username needed!') unless $Username;
Error('Option --password needed!') unless $Password;
Error('Option --warning needed!') unless $Warning;
Error('Option --critical needed!') unless $Critical;

#unless($Password) {
#  VMware::VICredStore::init(filename => "/etc/nagios3/.vmware/credstore/vicredentials.xml");
#  $Password = VMware::VICredStore::get_password(server => $Hostname, username => $Username);
#  VMware::VICredStore::close();
#}

$Hostname .= ":443" if (index($Hostname, ":") == -1);
$Hostname = "https://" . $Hostname . "/sdk/webService";

if(defined($Password)) {
  Util::connect($Hostname, $Username, $Password);
}

my $service_instance = Vim::get_service_instance();
my $esxtime = $service_instance->CurrentTime();
my $unix_esxtime = str2time($esxtime);

Util::disconnect();

my $localtime = localtime();
my $unix_localtime = str2time($localtime);

my $diff = $unix_esxtime - $unix_localtime;

if(($diff > $Warning) || ($diff < -$Warning)) {
  print "WARNING: NTP offset $diff second(s)\n";
  exit 1;
} elsif(($diff > $Critical) || ($diff < -$Critical)) {
	print "CRITICAL: NTP offset $diff second(s)\n";
	exit 2;
} else {
  print "OK: NTP offset $diff seconds\n";
  exit 0;
}

# End of file
