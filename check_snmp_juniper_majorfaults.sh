#!/bin/bash

# Skript um Juniper Devices auf Major Fault (Red Alarm) zu pruefen.
# Die zugehoerige OID lautet: .1.3.6.1.4.1.2636.3.4.2.3.1.0
# Rueckgabewerte:
# 1 = UNKNOWN
# 2 = OK
# 3 = CRITICAL
#
# 20240227 Torsten Bunde (github@torstenbunde.de)

# Icinga2 states
STATE_OK="0";
STATE_WARNING="1";
STATE_CRITICAL="2";
STATE_UNKNOWN="3";

# Tools
SNMPGET="/usr/bin/snmpget";
SNMPOID=".1.3.6.1.4.1.2636.3.4.2.3.1.0";

while getopts "H:c:" INPUT;
do
  case ${INPUT} in
	H) HOSTNAME="${OPTARG}";	# Servername oder IP-Adresse
	   ;;
	c) COMMUNITY="${OPTARG}";	# SNMP-Community
	   ;;
	*) echo "Falsche Optionen verwendet! -H <Hostname>, -c <SNMP-Community>";
	   exit 1;
	   ;;
  esac
done

if [ -z ${HOSTNAME} ] || [ -z ${COMMUNITY} ] ; then
  echo "usage: $0 -H <Hostname> -c <SNMP-Community";
  exit 3;
fi

# Hole Status vom Device
STATUS="$($SNMPGET -Ovq -v2c -c${COMMUNITY} ${HOSTNAME} ${SNMPOID})";

# Rueckgabewert
if [[ $STATUS == 2 ]]; then
  echo "OK";
  exit $STATE_OK;
elif [[ $STATUS == 3 ]]; then
  echo "CRITICAL";
  exit $STATE_CRITICAL;
else
  echo "UNKNOWN";
  exit $STATE_UNKNOWN;
fi

exit 0;

# End of file
