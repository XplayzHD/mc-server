#!/bin/sh
# script to setup and install Minecraft server scripts

#
# constants
#

LB='\033[1;94m'
RD='\033[1;31m'
GN='\033[1;32m'
YW='\033[1;33m'
NC='\033[0m'

ROOTDIR="$(pwd)/../server"
SERVICEDIR="/etc/systemd/system"
EXECDIR="/usr/local/bin"

#
# creating startup service
#

echo -e "${LB}installing/updating startup service...${NC}"

mkdir -p $SERVICEDIR
sudo cp minecraft.service $SERVICEDIR/

# reload daemon cache
systemctl daemon-reload

echo -e "${LB}\tenabling the startup service...${NC}"

while ! [[ $(systemctl is-enabled minecraft) == "enabled" ]]; do
  systemctl enable minecraft
done

#
# setting up server directory
#

echo -e "${LB}setting up server directory...${NC}"

echo -e "${LB}\tcreating directory...${NC}"
mkdir -p $EXECDIR/minecraft

echo -e "${LB}\tsaving server directory path...${NC}"
echo $ROOTDIR | tee $EXECDIR/minecraft/rootpath.txt

#
# updating server scripts 
#

echo -e "${LB}updating server scripts...${NC}"

echo -e "${LB}\tremoving old scripts...${NC}"
rm "$EXECDIR/minecraft/start.sh" >/dev/null 2>&1
rm "$EXECDIR/minecraft/stop.sh" >/dev/null 2>&1
rm "$EXECDIR/minecraft/restart.sh" >/dev/null 2>&1

echo -e "${LB}\tretrieving new scripts...${NC}"
sudo cp ../bin/start.sh $EXECDIR/minecraft
sudo cp ../bin/stop.sh $EXECDIR/minecraft
sudo cp ../bin/restart.sh $EXECDIR/minecraft

#
# installing depedencies
#

echo -e "${LB}installing dependencies...${NC}"

echo -e "${LB}\tinstalling java openjdk...${NC}"
yes | pacman -S jre-openjdk-headless
if ! java -version 2>&1 >/dev/null | egrep "\S+\s+version"; then
  echo -e "${RD}java could not be installed correctly. Aborting.${NC}"
  exit 1
fi

echo -e "${LB}\tinstalling screen...${NC}"
yes | pacman -S screen

echo -e "${LB}\tinstalling ssh...${NC}"
yes | pacman -S openssh
systemctl enable sshd

sed -i "s/.*#.*PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config

echo "export TERM=xterm" | tee -a ~/.bashrc


#
# configuring automatic reboot
#

echo -e "${LB}configuring automatic reboot...${NC}"

printf "1\ny" | pacman -S cron

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

#
# additional power settings
#

#logind="/etc/systemd/logind.conf"
#
#if grep -q "HandleLidSwitch=" $logind; then
#  sed -i "s/HandleLidSwitch=.*/HandleLidSwitch=ignore/g" $logind
#else
#  echo "HandleLidSwitch=ignore" | tee -a $logind >/dev/null 2>&1
#fi
#
#if grep -q "HandleLidSwitchExternalPower=" $logind; then
#  sed -i "s/HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/g" $logind
#else
#  echo "HandleLidSwitchExternalPower=ignore" | tee -a $logind >/dev/null 2>&1
#fi
#
#if grep -q "HandleLidSwitchDocked=" $logind; then
#  sed -i "s/HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/g" $logind
#else
#  echo "HandleLidSwitchDocked=ignore" | tee -a $logind >/dev/null 2>&1
#fi

#
# setup ssh
#

#grubConf="/etc/default/grub"
#
#if grep -q "GRUB_TIMEOUT=" $grubConf; then
#  sed "s/.*GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g" $grubConf | tee $grubConf
#else
#  echo "GRUB_TIMEOUT=0" | tee -a $grubConf
#fi
#
## twice for safety measures
#
#if grep -q "GRUB_TIMEOUT=" $grubConf; then
#  sed "s/.*GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g" $grubConf | tee $grubConf
#else
#  echo "GRUB_TIMEOUT=0" | tee -a $grubConf
#fi
#
#grub-mkconfig -o /boot/grub/grub.cfg

#
# system reboot
#

echo -e "${YW}The server has been successfully set up. Reboot the system to restart the server.${NC}"
