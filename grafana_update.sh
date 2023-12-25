#!/bin/bash
# Script name   : grafana_update.sh
# Description   : Skript um Icinga-Modul Grafana upzudaten
# Args          : None
# Author        : Torsten Bunde
# Email         : github@torstenbunde.de
# Date          : 20231206
# Version       : 0.1
# Usage         : bash grafana_update.sh
# Notes         : Mindestens die MODULE_VERSION muss vor einem Update im Skript selbst angepasst werden!
# Bash_version  : 5.1.16(1)-release

MODULE_VERSION="2.0.3"
ICINGAWEB_MODULEPATH="/usr/share/icingaweb2/modules"
REPO_URL="https://github.com/Mikesch-mp/icingaweb2-module-grafana"
TARGET_DIR="${ICINGAWEB_MODULEPATH}/grafana"
URL="${REPO_URL}/archive/v${MODULE_VERSION}.tar.gz"

# Abfrage, ob Versionsnummer angepasst wurde
echo "";
read -r -p "Muss die Variable der Versionsnummer (aktuell: ${MODULE_VERSION}) im Skript noch angepasst werden? [j/N] " response
if [[ "$response" =~ ^([jJ][aA]|[jJ]|[yY][eE][sS]|[yY])$ ]]; then
  echo "Beende Skript, bitte Variablen im Skript anpassen";
  echo "";
  exit 0;
fi

rm -rf ${TARGET_DIR}
install -d -m 0755 "${TARGET_DIR}"
wget -q -O - "$URL" | tar xfz - -C "${TARGET_DIR}" --strip-components 1

echo "Bitte in der Weboberflaeche ueberpruefen, ob Schema-Updates in der Datenbank durchgefuehrt werden muessen (-> Einstellungen -> System -> Migrations)";
exit 0;

# End of file
