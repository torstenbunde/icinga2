#!/bin/bash
# Script name	: director_update.sh
# Description	: Skript um Icinga-Modul Director upzudaten
# Args		: None
# Author	: Torsten Bunde
# Email		: github@torstenbunde.de
# Date		: 20231116
# Version	: 0.1
# Usage		: bash director_update.sh
# Notes		: Mindestens die MODULE_VERSION muss vor einem Update im Skript selbst angepasst werden!
# Bash_version	: 5.1.16(1)-release

MODULE_VERSION="1.11.0";
ICINGAWEB_MODULEPATH="/usr/share/icingaweb2/modules";
REPO_URL="https://github.com/icinga/icingaweb2-module-director";
TARGET_DIR="${ICINGAWEB_MODULEPATH}/director";
URL="${REPO_URL}/archive/v${MODULE_VERSION}.tar.gz";

# Abfrage, ob Versionsnummer angepasst wurde
echo "";
read -r -p "Muss die Variable der Versionsnummer (aktuell: ${MODULE_VERSION}) im Skript noch angepasst werden? [j/N] " response
if [[ "$response" =~ ^([jJ][aA]|[jJ]|[yY][eE][sS]|[yY])$ ]]; then
  echo "Beende Skript, bitte Variablen im Skript anpassen";
  echo "";
  exit 0;
fi

# Lege Verzeichnis mit mkdir nur an falls es nicht existiert (Option -p)
echo "Hole ${URL} und installiere Modul nach ${ICINGAWEB_MODULEPATH}";
install -d -m 0755 "${TARGET_DIR}"
wget -q -O - "$URL" | tar xfz - -C "${TARGET_DIR}" --strip-components 1

echo "Bitte in der Weboberflaeche ueberpruefen, ob Schema-Updates in der Datenbank durchgefuehrt werden muessen (-> Einstellungen -> System -> Migrations)";
exit 0;

# End of file
