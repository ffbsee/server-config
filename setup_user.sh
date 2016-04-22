#!/bin/bash

#	Dieses Script sorgt dafür, dass auf jeden VPN-Server
#	die richtigen User mit den richtigen berechtigungen angelegt sind.
#	Außerdem kann es zum Updaten verwendet werden wenn neue Nutzer angelegt sind.

# Globale Variablen:

ff_admin_group="ffbsee"



# Benutzerspezifische Variablen:

# Administratoren von Freifunk Bodensee:
FFADMIN=(tomoe lroller)


# SSH-Keys:
ssh_key_tomoe="\n"

ssh_key_lroller="# verwaltung.teledata-fn.local\n
ssh-rsa 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 lroller@verwaltung.teledata-fn.local
\n\n
# tomoe.de\n
ssh-rsa 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 lroller@tomoe.de"


# Developement options:
sleep_if_not_root="1"
execute_script="false"
install_enviroment="false"

# Script wird ausgeführt:

# Berechtigungen checken
if [ "$(id -u)" != "0" ]; then
   echo "This script should be run as root" 1>&2
   sleep $sleep_if_not_root
fi

# Gruppe $ff_admin_group

if getent group $ff_admin_group >/dev/null; then
  echo GRUPPENNAME vorhanden
else
  printf "Gruppe ffbsee wird angelegt\n"
  if $execute_script == "true"; then
    addgroup ffbsee
	sudo bash -c 'echo -e "%ffbsee ALL=NOPASSWD: ALL\n" | (EDITOR="tee -a" visudo)'
  else echo "!! Script wird nicht ausgeführt"  
  fi
fi


# Benutzer erkennen und ggf erstellen:
for user in "${FFADMIN[@]}"
do
  if getent passwd $user >/dev/null; then
    echo "BENUTZER: $user vorhanden!"
  else
    echo "BENUTZER: $user wird angelegt!" 
    if $execute_script == "true"; then	
      sudo adduser $user --ingroup $ff_admin_group --disabled-password --gecos ""
	  #2DO .bash... anlegen!
    else echo "!! Script wird nicht ausgeführt"
    fi	
  fi
  if groups $user | grep &>/dev/null "\b$ff_admin_group\b"; then
    echo -e "$user ist in der Gruppe $ff_admin_group\n"
  else
    echo -e "$user wird der Gruppe $ff_admin_group hinzugefuegt\n"
	if $execute_script == "true"; then
	  usermod -aG $ff_admin_group $user
    else echo "!! Script wird nicht ausgeführt"
    fi		
  fi
done

# Systemupdate
if $install_enviroment == "true"; then
  apt-get update
  apt-get upgrade -y
  apt-get install --assume-yes vim
fi
