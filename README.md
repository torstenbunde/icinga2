# icinga2

## Icingaweb2
* ```businessprocess_update.sh```: Skript um Icingaweb2-Modul Business Process upzudaten.
* ```check_vip.sh```: Skript um im HA-Modus bestimmte Services nur auf dem System mit der virtuellen IP (vIP) laufen zu lassen. IP-Adresse ($VIP) und Netzwerkkarte (hier: `bond0`) müssen entsprechend angepasst werden.
* ```director_update.sh```: Skript um Icingaweb2-Modul Director upzudaten.
* ```grafana_update.sh```: Skript um Icingaweb2-Modul Grafana upzudaten.
* ```pdfexport_update.sh```: Skript um Icingaweb2-Modul PDF Export upzudaten.
* ```reporting_update.sh```: Skript um Icingaweb2-Modul Reporting upzudaten.

## F5 (WAF)
* ```check_f5_time.sh```: Check um Zeitabweichung zweier F5-WAF-Systeme zu prüfen.

## Hewlett Packard Enterprise (HPE)
* ```check_hpe_firmware.sh```: Da das Skript [check_hp_firmware](https://github.com/NETWAYS/check_hp_firmware) ab einer Firmware-Version >= 3.00 bei iLO 5 derzeit Fehler wirft bzw. die Abfrage abbricht habe ich mir als Alternative ein Shellskript gebastelt, dass auf [check_redfish.py](https://github.com/bb-Ricardo/check_redfish) aufbaut und die zurückgegebenen Inventar-Daten auf eine Mindestversion prüft. Ich habe die Hoffnung aber noch nicht ganz aufgegeben, dass HPE das eigentliche Problem irgendwann einmal in den Griff bekommt ...

## Juniper
* ```check_junos_bgp_state.pl```: Check BGP State (Simple) - nagios plugin
* ```check_snmp_juniper_majorfaults.sh```: Check Major Fault (Red Alarm)
* ```check_snmp_juniper_subscribersallowed.sh```: Check Subscribers Allowed

## NTP/timesyncd
* ```check_systemd_timesyncd```: Check timesyncd running on Ubuntu 22.04 LTS
* ```check_vmware_ntp.pl```: Check NTP auf ESX-Servern.
