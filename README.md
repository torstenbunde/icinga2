# icinga2

## Icingaweb2
* ```businessprocess_update.sh```: Skript um Icingaweb2-Modul Business Process upzudaten.
* ```check_vip.sh```: Skript um im HA-Modus bestimmte Services nur auf dem System mit der virtuellen IP (vIP) laufen zu lassen. IP-Adresse ($VIP) und Netzwerkkarte (hier: `bond0`) müssen entsprechend angepasst werden.
* ```director_update.sh```: Skript um Icingaweb2-Modul Director upzudaten.
* ```grafana_update.sh```: Skript um Icingaweb2-Modul Grafana upzudaten.
* ```reporting_update.sh```: Skript um Icingaweb2-Modul Reporting upzudaten.

## Juniper
* ```check_junos_bgp_state.pl```: Check BGP State (Simple) - nagios plugin
* ```check_snmp_juniper_majorfaults.sh```: Check Major Fault (Red Alarm)
* ```check_snmp_juniper_subscribersallowed.sh```: Check Subscribers Allowed

## NTP/timesyncd
* ```check_systemd_timesyncd```: Check timesyncd running on Ubuntu 22.04 LTS
