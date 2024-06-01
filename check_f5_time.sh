#!/bin/bash
# Script name   : check_f5_time.sh
# Description   : Skript um die Zeitdifferenz zwischen zwei F5-WAF-Systemen zu ermitteln
# Args          : SNMP-Community, IP-Adressen beider F5-Systeme, Warning- und Critical-Wert in Sekunden
# Author        : Torsten Bunde
# Email         : github@torstenbunde.de
# Date          : 20211014
# Version       : 1.0
# Usage         : bash check_f5_time.sh

# Icinga2 Exit-Werte
OK="0";
WARNING="1";
CRITICAL="2";
UNKNOWN="3";

# Variablendeklaration
OID_TIMESTAMP=".1.3.6.1.2.1.25.1.2.0";
AWK="/usr/bin/awk";
BC="/usr/bin/bc";
DATE="/bin/date";
DIFF="/usr/bin/diff";
SED="/bin/sed";
SNMPGET="/usr/bin/snmpget";

while getopts "C:A:B:w:c:" INPUT;
do
  case ${INPUT} in
	C) COMMUNITY="${OPTARG}";	# SNMP-Community
	   ;;
	A) DEVICEA="${OPTARG}";		# IP-Adresse Device A
	   ;;
	B) DEVICEB="${OPTARG}";		# IP-Adresse Device B
	   ;;
	w) TIMEWARN="${OPTARG}";	# Warning-Wert als Integer fuer Wert in Sekunden
	   ;;
	c) TIMECRIT="${OPTARG}";  # Critical-Wert als Integer fuer Wert in Sekunden
	   ;;
	*) echo "Falsche Optionen verwendet! -C <SNMP-Community>, -A <Device A>, -B <Device B>, -c <CRITICAL>";
	   exit 1;
	   ;;
  esac
done

if [ -z ${COMMUNITY} ] || [ -z ${DEVICEA} ] || [ -z ${DEVICEB} ] || [ -z ${TIMEWARN} ] || [ -z ${TIMECRIT} ]; then
  echo "usage: $0 -C <SNMPCommunity> -A <DeviceA> -B <DeviceB> -w <WARNING> -c <CRITICAL>";
  exit 3;
fi

# Hole Zeitstempel von F5
TIMESTAMPA="$($DATE -d"$($SNMPGET -v2c -c "$COMMUNITY" -Oqv "$DEVICEA" "$OID_TIMESTAMP" 2>/dev/null | $SED 's/,/ /g' | $AWK -F' ' '{print $1,$2}')" +'%s' 2>/dev/null)";
TIMESTAMPB="$($DATE -d"$($SNMPGET -v2c -c "$COMMUNITY" -Oqv "$DEVICEB" "$OID_TIMESTAMP" 2>/dev/null | $SED 's/,/ /g' | $AWK -F' ' '{print $1,$2}')" +'%s' 2>/dev/null)";

# Pruefen, ob Werte zurueckgekommen sind. Es kann sein, dass Device
# keine Daten liefert oder der Check ins Timeout laeuft.
if ! [[ "$TIMESTAMPA" =~ ^[0-9]+$ ]]; then
  echo "UNKNOWN - ${DEVICEA} liefert keinen Wert."
  exit $UNKNOWN;
fi

if ! [[ "$TIMESTAMPB" =~ ^[0-9]+$ ]]; then
  echo "UNKNOWN - ${DEVICEB} liefert keinen Wert."
  exit $UNKNOWN;
fi

# Pruefen, um negativen Vergleichswert zu vermeiden.
if [ $TIMESTAMPB -gt $TIMESTAMPA ]; then
  TIMEDIFF="$($BC -l <<< "scale=10; $TIMESTAMPB-$TIMESTAMPA")";
else
  TIMEDIFF="$($BC -l <<< "scale=10; $TIMESTAMPA-$TIMESTAMPB")";
fi

# Auswertung
if [[ $TIMEDIFF -ge 0 && $TIMEDIFF -lt $TIMEWARN ]]; then
  echo "OK - Abweichung ${TIMEDIFF} Sekunden";
  exit $OK;
elif [[ $TIMEDIFF -ge $TIMEWARN && $TIMEDIFF -lt $TIMECRIT ]]; then
  echo "WARNING - Abweichung ${TIMEDIFF} Sekunden";
  exit $WARNING;
else
  echo "CRITICAL - Abweichung ${TIMEDIFF} Sekunden";
  exit $CRITICAL;
fi

exit 0;

# End of file
