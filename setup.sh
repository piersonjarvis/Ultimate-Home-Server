#!/bin/bash
sudo apt-get update && sudo apt-get upgrade -y
# Install necessary packages
sudo apt-get install unzip wget dialog -y
# install docker
curl -fsSL get.docker.com | sh 
wait
# adding user to docker group
sudo usermod -aG docker "$USER"
# installing docker compose
sudo apt-get install docker-compose -y
wait
sudo docker network create home
# download folder for installation
wget wget https://github.com/piersonjarvis/Ultimate-Home-Server/archive/master.zip
# preparing folder
unzip master.zip
sudo rm -r master.zip
sudo mv Ultimate-Home-Server-master Server
cd Server
mkdir configs
# setup domain name, if you have one this is where you will set it, if not it will default to localdomain
if dialog --stdout --title "Domain" --yesno "Do you have a certified domain?" 0 0;
then 
domain=$(dialog --stdout --title "domain" --inputbox "Please set domain name:" 0 0) && \
email=$(dialog --stdout --title "email" --inputbox "Please enter email address:" 0 0) && \
sed -e s/\#t//g -i docker-compose.yml && \
sed -e s/domainname/$domain/g -i ./traefik/traefik.toml
sed -e s/example@email/$email/g -i ./traefik/traefik.toml
else
domain=localdomain && \
sed -e s/\#l//g -i docker-compose.yml
fi
sed -e s/domainname/$domain/g -i docker-compose.yml
# server selection happens here
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
 sed -e s/\#1//g -i docker-compose.yml && mkdir ./media
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
uid=$(id -u)
gid=$(id -g)
echo "PUID=$uid" >> uidgid.env
echo "PGID=$gid" >> uidgid.env
docker-compose up -d
if [ -f "./configs/media/sabnzbd/sabnzbd.ini" ]
then
sed -e s/sabnzbd/sabnzbd.$domain/g ./configs/media/sabnzbd/sabnzbd.ini
fi
sudo crontab -l | { cat; echo "55 24 * * * docker system prune -a"; } | crontab -
docker restart $(docker ps -a -q)