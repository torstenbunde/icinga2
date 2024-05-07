#!/bin/bash
# Script name   : check_vip.sh
# Description   : Skript um Icinga Services nur auf dem System mit der vIP laufen zu lassen
# Args          : None
# Author        : Torsten Bunde
# Email         : github@torstenbunde.de
# Date          : 20240507
# Version       : 1.0
# Usage         : bash check_vip.sh
# Notes         : Skript sollte als Cron-Job (minuetlich oder so) laufen
#                 Die Module zu den Services muessen im Icinga Web 2 selbst aktiviert sein!
#		  Die virtuelle IP muss in der Variablen $VIP hinterlegt werden.
#		  Die zu ueberpruefenden Services muessen in der Variablen $SERVICES hinterlegt werden.

P="$(/usr/bin/basename $0)";
LOGFILE="/var/log/${P}.log";
VIP="<vIP>";	# <-- Add virtual IP address (vIP)
SERVICES="icinga-director icinga-vspheredb icinga-x509";

if [[ $(/usr/sbin/ip address show bond0 | /usr/bin/grep -z "$VIP" | /usr/bin/tr -d '\0') ]]; then
  # vIP liegt auf diesem System
  for SERVICE in $(echo $SERVICES)
  do
    # Pruefe ob Service inaktiv ist. Falls ja, starte ihn.
    if [ "$(/usr/bin/systemctl is-active $SERVICE)" == "inactive" ]; then
      echo "$(/bin/date +'%F %T'): Starte Service ${SERVICE}" >>$LOGFILE;
      $(/usr/bin/systemctl start $SERVICE);
    fi
  done
else
  # vIP liegt nicht auf diesem System
  for SERVICE in $(echo $SERVICES)
  do
    # Pruefe ob Service aktiv ist. Falls ja, stoppe ihn.
    if [ "$(/usr/bin/systemctl is-active $SERVICE)" == "active" ]; then
      echo "$(/bin/date +'%F %T'): Stoppe Service ${SERVICE}" >>$LOGFILE;
      $(/usr/bin/systemctl stop $SERVICE);
    fi
  done
fi

# End of file									
