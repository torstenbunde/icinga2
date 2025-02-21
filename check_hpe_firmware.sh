#!/bin/bash

# Script name   : check_hpe_firmware.sh
# Description   : Skript um mittels check_redfish (https://github.com/bb-Ricardo/check_redfish)
#		  auf eine Mindestversion der iLO-Firmware pruefen zu koennen.
# Args          : None
# Author        : Torsten Bunde
# Email         : github@torstenbunde.de
# Date          : 20250218
# Version       : 1.0
# Usage         : bash check_hpe_firmware.sh
# Notes         : Informationen zu verfuegbaren iLO-Firmware-Updates (Stand: 18.02.2025) gibt es unter:
# 		            HPE iLO 4: https://support.hpe.com/connect/s/softwaredetails?language=de&collectionId=MTX-2137f29484a3411e&tab=Fixes
# 		            HPE iLO 5: https://support.hpe.com/connect/s/softwaredetails?language=de&collectionId=MTX-2dc80c4ae4b943fa&tab=Fixes
# 		            HPE iLO 6: https://support.hpe.com/connect/s/softwaredetails?language=de&collectionId=MTX-fee0c98ee3b34ad8&tab=Fixes 

# Icinga2 states
STATE_OK="0";
STATE_WARNING="1";
STATE_CRITICAL="2";
STATE_UNKNOWN="3";

while getopts "4:5:6:H:p:u:" INPUT;
do
  case ${INPUT} in
	  4) MIN_ILO4="${OPTARG}";	# Minimale iLO4 Version
	     ;;
  	5) MIN_ILO5="${OPTARG}";	# Minimale iLO5 Version
	     ;;
  	6) MIN_ILO6="${OPTARG}";	# Minimale iLO6 Version
	     ;;
  	H) HOSTNAME="${OPTARG}";  # Servername oder IP-Adresse
       ;;
  	p) PASSWORD="${OPTARG}";	# Password for user
	     ;;
  	u) USERNAME="${OPTARG}";	# Username
	     ;;
    *) echo "Falsche Optionen verwendet! -H <Hostname> -u <Username> -p <Password> -4 <Min. iLO4 Version> -5 <Min. iLO5 Version> -6 <Min. iLO Version>";
       exit 1;
       ;;
  esac
done

if [ -z ${HOSTNAME} ] || [ -z ${MIN_ILO4} ] || [ -z ${MIN_ILO5} ] || [ -z ${MIN_ILO6} ] || [ -z ${PASSWORD} ] || [ -z ${USERNAME} ]; then
  echo "usage: $0 -H <Hostname> -u <Username> -p <Password> -4 <Min. iLO4 Version> -5 <Min. iLO5 Version> -6 <Min. iLO Version>";
  exit 3;
fi

# Tools
BC="/usr/bin/bc";
CUT="/usr/bin/cut";
JQ="/usr/bin/jq";
REDFISH="/usr/lib/nagios/plugins/check_redfish/check_redfish.py";
SED="/usr/bin/sed";
XARGS="/usr/bin/xargs";

read ILO FIRMWARE <<< $($REDFISH -H $HOSTNAME -u $USERNAME -p $PASSWORD --firmware --inventory | $JQ -r '.inventory.firmware[] | select (.name | startswith("iLO")) | .name, .version | sub(" ";"")' | $XARGS);
FIRMWARE="$(echo $FIRMWARE | $CUT -d' ' -f1 | $SED 's/[^0-9\.]*//g')";

case ${ILO} in
	iLO4) if (( $(echo "$FIRMWARE >= $MIN_ILO4" | $BC -l) )); then
          echo "OK - iLO4 firmware version ${FIRMWARE} is fine.";
          exit $STATE_OK;
	      elif (( $(echo "$FIRMWARE < $MIN_ILO4" | $BC -l) )); then
          echo "CRITICAL - iLO4 firmware version ${FIRMWARE} is smaller than $MIN_ILO4! Please update.";
          exit $STATE_CRITICAL;
	      else
          echo "UNKNOWN - State is unknown. Please check Server and/or script.";
          exit $STATE_UNKNOWN;
	      fi
	      ;;
	iLO5) if (( $(echo "$FIRMWARE >= $MIN_ILO5" | $BC -l) )); then
          echo "OK - iLO4 firmware version ${FIRMWARE} is fine.";
          exit $STATE_OK;
        elif (( $(echo "$FIRMWARE < $MIN_ILO5" | $BC -l) )); then
          echo "CRITICAL - iLO5 firmware version ${FIRMWARE} is smaller than $MIN_ILO5! Please update.";
          exit $STATE_CRITICAL;
        else
          echo "UNKNOWN - State is unknown. Please check Server and/or script.";
          exit $STATE_UNKNOWN;
        fi
        ;;
	iLO6) if (( $(echo "$FIRMWARE >= $MIN_ILO6" | $BC -l) )); then
          echo "OK - iLO6 firmware version ${FIRMWARE} is fine.";
          exit $STATE_OK;
        elif (( $(echo "$FIRMWARE < $MIN_ILO6" | $BC -l) )); then
          echo "CRITICAL - iLO6 firmware version ${FIRMWARE} is smaller than $MIN_ILO6! Please update.";
          exit $STATE_CRITICAL;
        else
          echo "UNKNOWN - State is unknown. Please check Server and/or script.";
          exit $STATE_UNKNOWN;
        fi
        ;;
esac

echo "UNKNOWN - Script does not match anything. Please check!";
exit $STATE_UNKNOWN;

# End of file
