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
EXECDIR="/usr/local/bin"

#
# optimizing the environment
#

echo -e "${GN}optimizing the environment...${NC}"

echo -e "${LB}\tdisabling bluetooth services...${NC}"
sudo systemctl stop bluetooth.service
sudo systemctl disable bluetooth.service

# https://www.instructables.com/id/Disable-the-Built-in-Sound-Card-of-Raspberry-Pi/
echo -e "${LB}\tdisabling alsa sound...${NC}"
blacklistAlsa="blacklist snd_bcm2835"
alsaConf=/etc/modprobe.d/alsa-blacklist.conf
grep -q "$blacklistAlsa" $alsaConf 2>/dev/null || echo "$blacklistAlsa" | sudo tee -a $alsaConf 1>/dev/null

# https://www.cnx-software.com/2019/07/26/how-to-overclock-raspberry-pi-4/
# https://hothardware.com/reviews/hot-clocked-pi-raspberry-pi-4-benchmarked-at-214-ghz
echo -e "${LB}\tsetting up cpu overclock...${NC}"
# prevent prompting dialogs
export APT_LISTCHANGES_FRONTEND=none
yes | sudo apt-get update
yes | sudo apt-get dist-upgrade
# experimental releases for (possibly) better cpu clocking capacities
yes | sudo rpi-update

bootConf=/boot/config.txt
overclockfreq=2147
overclockvoltage=6

if grep -q "arm_freq" $bootConf; then
  sed "s/.*arm_freq.*/arm_freq=$overclockfreq/g" $bootConf | sudo tee $bootConf 1>/dev/null
else
  echo "arm_freq=$overclockfreq" | sudo tee -a $bootConf 1>/dev/null
fi

if grep -q "over_voltage" $bootConf; then
  sed "s/.*over_voltage.*/over_voltage=$overclockvoltage/g" $bootConf | sudo tee $bootConf 1>/dev/null
else
  echo "over_voltage=$overclockvoltage" | sudo tee -a $bootConf 1>/dev/null
fi

echo -e "${GN}done.${NC}"

#
# creating startup service
#

echo -e "${GN}creating startup service...${NC}"

sudo mkdir -p $SERVICEDIR

echo -e "${LB}\tdownloading the startup service from the repository...${NC}"
# TODO update url
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/minecraft.service -o $SERVICEDIR/minecraft.service
sudo chmod 644 $SERVICEDIR/minecraft.service

# reload daemon cache
sudo systemctl daemon-reload

echo -e "${LB}\tenabling the startup service...${NC}"
while ! [[ $(sudo systemctl is-enabled minecraft) == "enabled" ]]; do
  sudo systemctl enable minecraft
done

echo -e "${GN}done.${NC}"

#
# setting up server directory
#

echo -e "${GN}setting up server directory...${NC}"

echo -e "${LB}\tcreating directory...${NC}"
sudo mkdir -p $ROOTDIR
sudo mkdir -p $EXECDIR/minecraft

echo -e "${LB}\tsaving server directory path...${NC}"
echo $ROOTDIR | sudo tee $EXECDIR/minecraft/rootpath.txt >/dev/null 2>&1

echo -e "${LB}\tstoring endpoint url...${NC}"
echo -e "${YW}enter an endpoint url or press ENTER to continue with any previously entered url. This can always be updated later in $ROOTDIR/server.endpoint:${NC}"
read endpoint
if [[ ! -z $endpoint ]]; then
  echo $endpoint | sudo tee $ROOTDIR/server.endpoint >/dev/null 2>&1
else
  sudo touch $ROOTDIR/server.endpoint
fi

echo -e "${GN}done.${NC}"

echo -e "${YW}enter a name for your world. Default is ${LB}ServerWorld${YW}. This can always be updated later in $ROOTDIR/server.name:${NC}"
read worldName
test -z "$worldName" && ! test -f $ROOTDIR/server.name && worldName="ServerWorld"
! test -z "$worldName" && echo "$worldName" | sudo tee $ROOTDIR/server.name >/dev/null 2>&1

#
# updating server scripts 
#

echo -e "${GN}updating server scripts...${NC}"

echo -e "${LB}\tremoving old scripts...${NC}"
sudo rm "$EXECDIR/minecraft/start.sh" >/dev/null 2>&1
sudo rm "$EXECDIR/minecraft/stop.sh" >/dev/null 2>&1
sudo rm "$EXECDIR/minecraft/restart.sh" >/dev/null 2>&1

echo -e "${LB}\tretrieving new scripts...${NC}"
# TODO update urls
sudo curl -s "https://raw.githubusercontent.com/bossley9/mc-server/rework/start.sh" -o "$EXECDIR/minecraft/start.sh"
sudo chmod 755 "$EXECDIR/minecraft/start.sh"
sudo curl -s "https://raw.githubusercontent.com/bossley9/mc-server/rework/stop.sh" -o "$EXECDIR/minecraft/stop.sh"
sudo chmod 755 "$EXECDIR/minecraft/stop.sh"
sudo curl -s "https://raw.githubusercontent.com/bossley9/mc-server/rework/restart.sh" -o "$EXECDIR/minecraft/restart.sh"
sudo chmod 755 "$EXECDIR/minecraft/restart.sh"

echo -e "${GN}done.${NC}"

#
# installing depedencies
#

echo -e "${GN}installing dependencies...${NC}"
yes | sudo apt-get update

echo -e "${LB}\tinstalling java 8 jdk...${NC}"
yes | sudo apt-get install openjdk-8-jre-headless
if ! [ -n "`which java`" ]; then
  echo -e "${RD}java could not be installed correctly. Aborting.${NC}"
  exit 1
fi

echo -e "${LB}\tinstalling screen...${NC}"
yes | sudo apt-get install screen 
if ! [ -n "`which screen`" ]; then
  echo -e "${RD}screen could not be installed correctly. Aborting.${NC}"
  exit 1
fi

echo -e "${GN}done.${NC}"

#
# configuring automatic reboot
#

echo -e "${GN}configuring automatic reboot...${NC}"

echo -e "${LB}current system time is $(date)."
echo -e "${YW}automatically reboot and update server at 4AM daily? This can always be changed via crontab -e. [Y/N]${NC}"
read bAutoReboot
case $bAutoReboot in
  [Yy]*)
    croncmd="$EXECDIR/minecraft/restart.sh"
    cronjob="0 4 * * * $croncmd"
    ( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab - >/dev/null 2>&1
    ;;
esac

echo -e "${GN}done.${NC}"

#
# system reboot
#

echo -e "${YW}The system needs to reboot for the server to run properly. Reboot? [Y/N] ${NC}"
read bReboot
case $bReboot in
  [Yy]*)
    sudo reboot
    ;;
  *) echo -e "${RD}aborting setup.${NC}";
esac

