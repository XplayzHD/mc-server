#!/bin/bash
# script to setup and install the server scripts

#
# constants
#

LB='\033[1;94m'
RD='\033[1;31m'
GN='\033[1;32m'
YW='\033[1;33m'
NC='\033[0m'

ROOTDIR=$HOME/.mc-server
SERVICEDIR=/etc/systemd/system
EXECDIR=/usr/local/bin

#
# optimizing the environment
#

echo -e "${LB}optimizing the environment...${NC}"

echo -e "\tdisabling bluetooth services..."
sudo systemctl stop bluetooth.service
sudo systemctl disable bluetooth.service

# https://www.instructables.com/id/Disable-the-Built-in-Sound-Card-of-Raspberry-Pi/
echo -e "\tdisabling alsa sound..."
echo -e "blacklist snd_bcm2835" | sudo tee -a /etc/modprobe.d/alsa-blacklist.conf 1>/dev/null

# https://www.cnx-software.com/2019/07/26/how-to-overclock-raspberry-pi-4/
# https://hothardware.com/reviews/hot-clocked-pi-raspberry-pi-4-benchmarked-at-214-ghz
echo -e "\tsetting up cpu overclock..."
sudo apt-get update && sudo apt-get dist-upgrade
# experimental releases for (possibly) better cpu clocking capacities
sudo rpi-update
overclockfreq=2147
overclockvoltage=6

echo "$(sed "s/arm_freq=.*/arm_freq=$overclockcpu/g" /boot/config.txt)" | sudo tee /boot/config.txt 1>/dev/null
echo "$(sed "s/over_voltage=.*/over_voltage=$overclockvoltage/g" /boot/config.txt)" | sudo tee /boot/config.txt 1>/dev/null

echo -e "${GN}done.${NC}"

#
# creating startup service
#

echo -e "${LB}creating startup service...${NC}"

sudo mkdir -p $SERVICEDIR

echo -e "\tdownloading the startup service from the repository..."
# TODO update url
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/minecraft.service -o $SERVICEDIR/minecraft.service
sudo chmod 644 $SERVICEDIR/minecraft.service

# reload daemon cache
sudo systemctl daemon-reload

echo -e "\tenabling the startup service..."
while ! [[ $(sudo systemctl is-enabled minecraft) == "enabled" ]]; do
  sudo systemctl enable minecraft
done

echo -e "${GN}done.${NC}"

#
# setting up server directory
#

echo -e "${LB}setting up server directory...${NC}"

echo -e "\tcreating directory..."
sudo mkdir -p $ROOTDIR
sudo mkdir -p $EXECDIR

echo -e "\tsaving server directory path..."
echo $ROOTDIR | sudo tee $EXECDIR/minecraftrootpath.txt 1>/dev/null

echo -e "\tstoring endpoint url..."
sudo truncate -s 0 $ROOTDIR/server.endpoint
echo -e "${YW}enter an endpoint url or press ENTER to continue without one. This can always be updated later in $ROOTDIR/server.endpoint:${NC}"
read endpoint
if [[ ${#endpoint} > 0 ]]; then
  echo $endpoint | sudo tee $ROOTDIR/server.endpoint 1>/dev/null
fi

echo -e "${GN}done.${NC}"

echo -e "${YW}enter a name for your world. Default is ${LB}ServerName${YW}. This can always be updated later in $ROOTDIR/server.name:${NC}"
read worldName
if [[ ${#worldName} == 0 ]]; then worldName="ServerName"; fi

echo $worldName | sudo tee $ROOTDIR/server.name 1>/dev/null

#
# updating server scripts 
#

echo -e "${LB}updating server scripts...${NC}"

echo -e "\tremoving old scripts..."
sudo rm $EXECDIR/minecraftstart.sh 2>/dev/null
sudo rm $EXECDIR/minecraftstop.sh 2>/dev/null
sudo rm $EXECDIR/minecraftrestart.sh 2>/dev/null

echo -e "\tretrieving new scripts..."
# TODO update urls
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/start.sh -o $EXECDIR/minecraftstart.sh
sudo chmod 754 $EXECDIR/minecraftstart.sh
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/stop.sh -o $EXECDIR/minecraftstop.sh
sudo chmod 754 $EXECDIR/minecraftstop.sh
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/restart.sh -o $EXECDIR/minecraftrestart.sh
sudo chmod 754 $EXECDIR/minecraftrestart.sh

echo -e "${GN}done.${NC}"

#
# installing depedencies
#

echo -e "${LB}installing dependencies...${NC}"
sudo apt-get update

echo -e "\tinstalling java 8 jdk..."
sudo apt-get install openjdk-8-jre-headless
if ! [ -n "`which java`" ]; then
  echo -e "${RD}java could not be installed correctly. Aborting.${NC}"
  exit 1
fi

echo -e "\tinstalling screen..."
sudo apt-get install screen 
if ! [ -n "`which screen`" ]; then
  echo -e "${RD}screen could not be installed correctly. Aborting.${NC}"
  exit 1
fi

#
# configuring automatic reboot
#

echo -e "${LB}configuring automatic reboot...${NC}"

echo -e "${LB}current system time is $(date)."
echo -e "${YW}automatically reboot and update server at 4AM daily? This can always be changed via crontab -e. [Y/N]${NC}"
read bAutoReboot
case $bAutoReboot in
  [Yy]*)
    croncmd=$EXECDIR/minecraftrestart.sh
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
    ;;
esac

#
# system reboot
#

echo -e "${YW}The system needs to reboot for the server to run properly. Reboot? [Y/N] ${NC}"
read bReboot
case $bReboot in
  [Yy]*)
    sudo reboot
    ;;
  *) echo -e "${LB}aborting setup.${NC}";
esac

