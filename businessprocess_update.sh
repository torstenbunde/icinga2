#!/bin/bash
# Script name	: businessprocess_update.sh
# Description	: Skript um Icinga-Modul Business Process upzudaten
# Args		: None
# Author	: Torsten Bunde
# Email		: github@torstenbunde.de
# Date		: 20240426
# Version	: 0.1
# Usage		: bash businessprocess_update.sh
# Notes		: Mindestens die MODULE_VERSION muss vor einem Update im Skript selbst angepasst werden!
# Bash_version	: 5.1.16(1)-release

MODULE_NAME="businessprocess"
MODULE_VERSION="v2.5.1"
MODULE_AUTHOR="Icinga"
MODULES_PATH="/usr/share/icingaweb2/modules"
MODULE_PATH="${MODULES_PATH}/${MODULE_NAME}"
RELEASES="https://github.com/${MODULE_AUTHOR}/icingaweb2-module-${MODULE_NAME}/archive"

# Abfrage, ob Versionsnummer angepasst wurde
echo "";
read -r -p "Muss die Variable der Versionsnummer (aktuell: ${MODULE_VERSION}) im Skript noch angepasst werden? [j/N] " response
if [[ "$response" =~ ^([jJ][aA]|[jJ]|[yY][eE][sS]|[yY])$ ]]; then
  echo "Beende Skript, bitte Variablen im Skript anpassen";
  echo "";
  exit 0;
fi

# Lege Verzeichnis mit mkdir nur an falls es nicht existiert (Option -p)
echo "Hole ${RELEASES}/${MODULE_VERSION}.tar.gz und installiere Modul nach ${MODULE_PATH}";
mkdir -p "$MODULE_PATH" && wget -q $RELEASES/${MODULE_VERSION}.tar.gz -O - | tar xfz - -C "$MODULE_PATH" --strip-components 1

echo "Bitte in der Weboberflaeche ueberpruefen, ob Schema-Updates in der Datenbank durchgefuehrt werden muessen (-> Einstellungen -> System -> Migrations)";
exit 0;

# End of file
