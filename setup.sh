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
# sudo systemctl stop bluetooth.service
# sudo systemctl disable bluetooth.service

# https://www.instructables.com/id/Disable-the-Built-in-Sound-Card-of-Raspberry-Pi/
echo -e "\tdisabling alsa sound..."
# echo -e "blacklist snd_bcm2835" | sudo tee -a /etc/modprobe.d/alsa-blacklist.conf 1>/dev/null

# https://www.cnx-software.com/2019/07/26/how-to-overclock-raspberry-pi-4/
# https://hothardware.com/reviews/hot-clocked-pi-raspberry-pi-4-benchmarked-at-214-ghz
echo -e "\tsetting up cpu overclock..."
overclock="arm_freq=2140\nover_voltage=6"

# if ! awk "/$overclock/" /boot/config.txt; then
  # echo -e "$overclock" | sudo tee -a /boot/config.txt 1>/dev/null
# fi

echo -e "${GN}done.${NC}"

#
# creating startup service
#

echo -e "${LB}creating startup service...${NC}"

echo -e "\tdownloading the startup service from the repository..."
# TODO update url
# sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/minecraft.service -o $SERVICEDIR/minecraft.service
# sudo chmod 644 $SERVICEDIR/minecraft.service

# reload daemon cache
# sudo systemctl daemon-reload

echo -e "\tenabling the startup service..."
# sudo systemctl enable minecraftserver

echo -e "${GN}done.${NC}"

#
# setting up server directory
#

echo -e "${LB}setting up server directory...${NC}"

echo -e "\tcreating directory..."
mkdir -p $ROOTDIR

echo -e "\tsaving server directory path..."
# echo $ROOTDIR | sudo tee $EXECDIR/minecraft/rootpath.txt 1>/dev/null

echo -e "\tstoring endpoint url..."
sudo truncate -s 0 $ROOTDIR/server.endpoint
# read -p "$(echo -e "${YW}enter an endpoint url or press ENTER to continue without one (this can always be updated later in $ROOTDIR/server.endpoint):\n${NC} ")" endpoint
echo -e "${YW}enter an endpoint url or press ENTER to continue without one (this can always be updated later in $ROOTDIR/server.endpoint):\n${NC}"
read endpoint
if [[ ${#endpoint} > 0 ]]; then
  echo $endpoint | sudo tee $ROOTDIR/server.endpoint 1>/dev/null
fi

echo -e "${GN}done.${NC}"

#
# updating server scripts 
#

echo -e "${LB}updating server scripts...${NC}"

echo -e "\tremoving old scripts..."
# sudo rm $EXECDIR/minecraft/start.sh 2>/dev/null
# sudo rm $EXECDIR/minecraft/stop.sh 2>/dev/null
# sudo rm $EXECDIR/minecraft/restart.sh 2>/dev/null

echo -e "\tretrieving new scripts..."
# TODO update urls
# sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/start.sh -o $EXECDIR/minecraft/start.sh
# sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/stop.sh -o $EXECDIR/minecraft/stop.sh
# sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/restart.sh -o $EXECDIR/minecraft/restart.sh
# sudo chmod 754 $EXECDIR/minecraft/*.sh

echo -e "${GN}done.${NC}"

#
# installing depedencies
#

echo -e "${LB}installing dependencies...${NC}"
# sudo apt-get update

echo -e "\tinstalling java 8 jdk..."
# sudo apt-get install openjdk-8-jre-headless
if ! [ -n "`which java`" ]; then
  echo -e "${RD}java could not be installed correctly. Aborting.${NC}"
  exit 1
fi

#
# configuring automatic reboot
#

echo -e "${LB}configuring automatic reboot...${NC}"

echo -e "${LB}current system time is $(date)."
echo -e "${YW}automatically reboot and update server at 4AM daily? You can always change this via crontab -e. [Y/N]"
read bAutoReboot
case $bAutoReboot in
  [Yy]*)
    croncmd=$EXECDIR/minecraft/restart.sh
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
    ;;
esac

#
# system reboot
#

# read -p "$(echo -e "${YW}The system needs to reboot for the server to run properly. Reboot? [Y/N] ${NC}")" bReboot
echo -e "${YW}The system needs to reboot for the server to run properly. Reboot? [Y/N] ${NC}"
read bReboot
case $bReboot in
  [Yy]*)
    # TODO reboot
    echo "TODO rebooting"
    ;;
  *) echo -e "${LB}aborting setup.${NC}";
esac

