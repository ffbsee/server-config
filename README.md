Freifunk-Bodensee Server
===============
ACHTUNG! Das ist nur ein ganz frischer, schlechter Fork der ffulm server config.
Funktioniert noch nicht fuer ffbsee und ist nur ein ganz frischer Anfang.


Scripte und Konfigurationsdateien zum schnellen Einrichten eines Servers für Freifunk-Bodensee.
Vorausgesetzt wird eine Debian 8 Installation (Jessie).
Um einen Server einzurichten, reicht es, das Script "setup_server.sh" als Benutzer 'root' auszuführen:

```
apt-get install git
git clone https://github.com/ffbsee/server-config.git
cd server-config
./setup_server.sh
```

Nach erfolgreichem Einrichten wird das Script "/opt/freifunk/update.sh" alle 5 Minuten
von crond aufgerufen. Dadurch wird die Karte regelmäßig aktualisiert und nach
einem Neustart notwendige Programme neu gestartet.

### Server
Für die Serverfunktion werden folgende Programme installiert und automatisch konfiguriert:

 * Routingprotokoll: [batman-adv](http://www.open-mesh.org/projects/batman-adv/wiki)
 * FF-VPN: [fastd](https://projects.universe-factory.net/projects/fastd/wiki)
 * Webserver: lighttpd
 * Karte: [ffmap](https://github.com/ffnord/ffmap-d3)

### Gateway
Wird die Variable "setup_gateway" im Setup-Script auf "true" gesetzt, wird der Server zusätzlich
als Gateway eingerichtet. Das Script erwartet dann eine ZIP-Datei mit den Accountdaten
von mullvad.net im gleichen Verzeichnis. Zum Testen eignet sich ein anonymer Testaccount
für drei Stunden.

Für die Gatewayfunktion werden folgende Programme installiert und automatisch konfiguriert:

 * NAT64: [tayga](http://www.litech.org/tayga/)
 * DNS64: bind
 * IPv6 Router Advertisment: radvd
 * Auslands-VPN: OpenVPN

### IPv4
Durch die Reaktivierung von IPv4 im Freifunk Netz werden weitere Dienste benötigt:
 * DHCP (isc-dhcp-server)

Alle Serverbetreiber müssen sich absprechen, was den Bereich der verteilten DHCP Adressen angeht, damit es zu keinen Adresskonflikten kommt. Bisher wurden folgende Bereiche vergeben:

 * vpn1: unklar range unklar unklar
 
 
Innerhalb des Freifunknetzes gibt es die DNS Zone ".ffbsee". D.h. es können auch Namen wie "meinserver.ffbsee" aufgelöst werden. Masterserver dafür ist zur Zeit vpn5.
Falls weitere Server hinzugefügt werden, müssen die Zonendateien auf dem Master (db.10.unklar, db.ffbsee, named.conf.local) manuell angepasst werden. Hierzu bitte auf der Mailingliste melden.

### alfred
Des Weiteren sollte mindestens ein Server mit dem Schalter "-m" als alfred master betrieben werden. Zur Zeit ist dies vpn6.
https://github.com/ffbsee/server-config/blob/master/freifunk/update.sh#L121

### Netz
Freifunk Bodensee nutzt folgende Netze (pull request beim icvpn noch nicht durch):
 * ipv4: ```10.11.160.0/20```
 * ipv6: ```fdef:1701:b5ee::/48```
 
Durchsatz und Statistiken
-----
Es wird vnstat und munin auf den Gateways verwendet. Wenn dies nicht gewünscht wird, muss die Variable "setup_statistics" auf "false" gesetzt werden. Die Software für munin clients wird automatisch eingerichtet, der master server für munin ist z.Z. vpn5 und wird folgendermaßen konfiguriert:

### munin master
```
apt-get install munin
cd /var/www
ln -s /var/cache/munin/www/munin
```
Dann unter /etc/munin.conf anpassen und alle clients eintragen:
```
#[localhost.localdomain]
#    address 127.0.0.1
#    use_node_name yes
[vpn1.ffbsee]
     address 10.11.160.1

```
Daemon neustarten
```
/etc/init.d/munin restart
```

ICVPN
-----
Folgende Adressen wurden NOCH NICHT im [Transfernetz des ICVPN] (https://github.com/freifunk/icvpn-meta/blob/master/bodensee) für die Bodensee community reserviert:

vpn1
 * ipv4: ```10.11.160.1```
 * ipv6: ```fded:1701:b5ee:1```

Doku zu ICVPN bei FF Bielefeld: (veraltet)
https://wiki.freifunk-bielefeld.de/doku.php?id=ic-vpn

Tinc aus Debian jessie ist (angeblich) nicht stabil genug.
Tinc 1.11 pre selbst bauen:
https://gist.github.com/mweinelt/efff4fb7eba1ee41ef2d

ICVPN im Freifunk wiki:
https://wiki.freifunk.net/IC-VPN

DNS im Freifunk wiki:
https://wiki.freifunk.net/DNS

Die Konfig sollte automatisch per cron.hourly/daily aktualisiert werden: 
```
#!/bin/sh

DATADIR=/var/lib/icvpn-meta

# pull new public keys of peering partners for tinc vpn daemon from https://github.com/freifunk/icvpn
cd /etc/tinc/icvpn
git pull -q

# pull new bgp configs of peering partners from https://github.com/freifunk/icvpn-meta
cd "$DATADIR"
git pull -q

# refresh bgp config v4/v6
sudo -u nobody /opt/icvpn-scripts/mkbgp -4 -f bird -d peers -s "$DATADIR" -x bodensee > /etc/bird/bird.d/icvpn.conf
sudo -u nobody /opt/icvpn-scripts/mkbgp -6 -f bird -d peers -s "$DATADIR" -x bodensee -t berlin:upstream > /etc/bird/bird6.d/icvpn.conf

# reload bird v4/v6
birdc configure > /dev/null
birdc6 configure > /dev/null

# refresh DNS config for freifunk zones
sudo -u nobody /opt/icvpn-scripts/mkdns -f bind -s "$DATADIR" -x bodensee > /etc/bind/named.conf.freifunk

# reload bind9 config
/etc/init.d/bind9 reload > /dev/null
```
