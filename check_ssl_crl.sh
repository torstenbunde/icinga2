#!/bin/bash

# Script name   : check_ssl_crl.sh
# Description   : Skript um zu pruefen, ob die CRL-Datei von der Gueltigkeit her noch
#                 ausserhalb der Schwellwerte liegt. Die CRL-Datei liegt dabei lokal!
#                 Warning und Critical werden in Tagen angegeben.
# Args          : None
# Author        : Torsten Bunde
# Email         : github@torstenbunde.de
# Date          : 20260605
# Version       : 1.0
# Usage         : bash check_ssl_crl.sh '<CRLDATEI>' '<WARNING>' '<CRITIACL>'
# Notes         : 

# Icinga2 states
STATE_OK="0";
STATE_WARNING="1";
STATE_CRITICAL="2";
STATE_UNKNOWN="3";

# Variablendeklarationen
CRLDATEI="$1";
WARNING="$2";
CRITICAL="$3";
CUT="/usr/bin/cut";
DATE="/usr/bin/date";
OPENSSL="/usr/bin/openssl";

# Parameterpruefung
if [ -z "$CRLDATEI" ] || [ -z "$WARNING" ] || [ -z "$CRITICAL" ]; then
  echo "UNKNOWN - Fehlende Parameter! Nutzung: $0 <CRL-Datei inklusive Pfad> <Warning in Tagen> <Critical in Tagen>";
  exit $STATE_UNKNOWN;
fi

# Existiert die Datei?
if [ ! -f "$CRLDATEI" ]; then
  echo "CRITICAL - CRL-Datei nicht gefunden oder nicht lesbar: $CRLDATEI";
  exit $STATE_CRITICAL;
fi

# Ablaufdatum auslesen
NEXT_UPDATE="$($OPENSSL crl -in "$CRLDATEI" -noout -nextupdate 2>/dev/null | $CUT -d"=" -f2)";

# Konnte die Datei mittels OpenSSL korrekt geparsed werden?
if [ -z "$NEXT_UPDATE" ]; then
  echo "CRITICAL - Datei konnte nicht als CRL gelesen werden (ist es echtes PEM-Format?)";
  exit $STATE_CRITICAL;
fi

# Datum in Sekunden umrechnen
NEXT_UPDATE_SEC="$($DATE -d "$NEXT_UPDATE" +%s)";
NOW_SEC="$($DATE +%s)";

# Restlaufzeit in Tagen berechnen
REMAINING_DAYS="$(( (NEXT_UPDATE_SEC - NOW_SEC) / 86400 ))";

# Perfdata für Icinga-Graphen vorbereiten
PERFDATA="crl_days_left=${REMAINING_DAYS};${WARNING};${CRITICAL};0";

# Schwellenwerte prüfen und Icinga-Status ausgeben
if [ "$REMAINING_DAYS" -le "$CRITICAL" ]; then
  echo "CRITICAL - CRL laeuft in ${REMAINING_DAYS} Tagen ab! (Ablaufdatum: ${NEXT_UPDATE}) | ${PERFDATA}";
  exit $STATE_CRITICAL;
elif [ "$REMAINING_DAYS" -le "$WARNING" ]; then
  echo "WARNING - CRL laeuft in ${REMAINING_DAYS} Tagen ab! (Ablaufdatum: ${NEXT_UPDATE}) | ${PERFDATA}";
  exit $STATE_WARNING;
else
  echo "OK - CRL ist noch ${REMAINING_DAYS} Tage gueltig. (Ablaufdatum: ${NEXT_UPDATE}) | ${PERFDATA}";
  exit $STATE_OK;
fi

echo "UNKNOWN - Das Skript sollte hier eigentlich niemals ankommen, bitte pruefen!";
exit $STATE_UNKNOWN;

# End of file
