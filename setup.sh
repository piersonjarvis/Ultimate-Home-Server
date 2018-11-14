#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install unzip wget -y
curl -fsSL get.docker.com | sh 
wait
sudo usermod -aG docker "$USER"
sudo apt-get install docker-compose dialog -y
servers=(dialog --separate-output --checklist "Select Servers You Would Like Installed:" 0 0 0)
options=(1 "Media Server" off 
2 "Game Server (minecraft only)" off 
3 "Game Server (amp)" off
4 "Nextcloud" off 
5 "Web Managers" off)
selections=$("${servers[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
for selection in $selections
do
 case $selection in
 1)
 sed -e s/\#1//g -i docker-compose.yml
 ;;
 2)
 sed -e s/\#2//g -i docker-compose.yml
 ;;
 3)
 sed -e s/\#3//g -i docker-compose.yml
 ;;
 4)
 sed -e s/\#4//g -i docker-compose.yml
 ;;
 5)
 sed -e s/\#5//g -i docker-compose.yml
 ;;
 esac
done
if dialog --stdout --title "Domain" --yesno "Do you have a certified domain?" 0 0;
then 
domain=$(dialog --stdout --title "domain" --inputbox "Please set domain name:" 0 0)
else
domain=localhost
fi
sed -e s/domainname/$domain/g -i docker-compose.yml

