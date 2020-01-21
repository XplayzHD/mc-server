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

ROOTDIR="$HOME/minecraft"
SERVICEDIR="/etc/systemd/system"
EXECDIR="/usr/local/bin"

#
# optimizing the environment
#

echo -e "${GN}upgrading packages...${NC}"

yes | pacman -Syyuu

echo -e "${GN}done.${NC}"

#
# creating startup service
#

echo -e "${GN}creating startup service...${NC}"

mkdir -p $SERVICEDIR

echo -e "${LB}\tdownloading the startup service from the repository...${NC}"
curl https://raw.githubusercontent.com/bossley9/mc-server/master/minecraft.service -o $SERVICEDIR/minecraft.service
chmod u+x $SERVICEDIR/minecraft.service

# reload daemon cache
systemctl daemon-reload

echo -e "${LB}\tenabling the startup service...${NC}"
while ! [[ $(systemctl is-enabled minecraft) == "enabled" ]]; do systemctl enable minecraft; done

echo -e "${GN}done.${NC}"

#
# setting up server directory
#

echo -e "${GN}setting up server directory...${NC}"

echo -e "${LB}\tcreating directory...${NC}"
mkdir -p $ROOTDIR
mkdir -p $EXECDIR/minecraft

echo -e "${LB}\tsaving server directory path...${NC}"
echo $ROOTDIR | tee $EXECDIR/minecraft/rootpath.txt

echo -e "${LB}\tstoring endpoint url...${NC}"
echo -e "${YW}enter an endpoint url or press ENTER to continue with any previously entered url. This can always be updated later in $ROOTDIR/server.endpoint:${NC}"
read endpoint
if [[ ! -z $endpoint ]]; then
  echo $endpoint | tee $ROOTDIR/server.endpoint
else
  touch $ROOTDIR/server.endpoint
fi

echo -e "${GN}done.${NC}"

echo -e "${YW}enter a name for your world. Default is ${LB}ServerWorld${YW}. This can always be updated later in $ROOTDIR/server.name:${NC}"
read worldName
test -z "$worldName" && ! test -f $ROOTDIR/server.name && worldName="ServerWorld"
! test -z "$worldName" && echo "$worldName" | tee $ROOTDIR/server.name

#
# updating server scripts 
#

echo -e "${GN}updating server scripts...${NC}"

echo -e "${LB}\tremoving old scripts...${NC}"
rm "$EXECDIR/minecraft/start.sh" >/dev/null 2>&1
rm "$EXECDIR/minecraft/stop.sh" >/dev/null 2>&1
rm "$EXECDIR/minecraft/restart.sh" >/dev/null 2>&1

echo -e "${LB}\tretrieving new scripts...${NC}"
curl "https://raw.githubusercontent.com/bossley9/mc-server/master/desktop/start.sh" -o "$EXECDIR/minecraft/start.sh"
chmod u+x "$EXECDIR/minecraft/start.sh"
curl "https://raw.githubusercontent.com/bossley9/mc-server/master/desktop/stop.sh" -o "$EXECDIR/minecraft/stop.sh"
chmod u+x "$EXECDIR/minecraft/stop.sh"
curl "https://raw.githubusercontent.com/bossley9/mc-server/master/desktop/restart.sh" -o "$EXECDIR/minecraft/restart.sh"
chmod u+x "$EXECDIR/minecraft/restart.sh"

echo -e "${GN}done.${NC}"

#
# installing depedencies
#

echo -e "${GN}installing dependencies...${NC}"

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

echo -e "${GN}done.${NC}"

#
# configuring automatic reboot
#

echo -e "${GN}configuring automatic reboot...${NC}"

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

echo -e "${GN}done.${NC}"

#
# power settings
#

logind="/etc/systemd/logind.conf"

if grep -q "HandleLidSwitch=" $logind; then
  sed -i "s/HandleLidSwitch=.*/HandleLidSwitch=ignore/g" $logind
else
  echo "HandleLidSwitch=ignore" | tee -a $logind >/dev/null 2>&1
fi

if grep -q "HandleLidSwitchExternalPower=" $logind; then
  sed -i "s/HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/g" $logind
else
  echo "HandleLidSwitchExternalPower=ignore" | tee -a $logind >/dev/null 2>&1
fi

if grep -q "HandleLidSwitchDocked=" $logind; then
  sed -i "s/HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/g" $logind
else
  echo "HandleLidSwitchDocked=ignore" | tee -a $logind >/dev/null 2>&1
fi

#
# setup ssh
#

grubConf="/etc/default/grub"

if grep -q "GRUB_TIMEOUT=" $grubConf; then
  sed "s/.*GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g" $grubConf | tee $grubConf
else
  echo "GRUB_TIMEOUT=0" | tee -a $grubConf
fi

# twice for safety measures

if grep -q "GRUB_TIMEOUT=" $grubConf; then
  sed "s/.*GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g" $grubConf | tee $grubConf
else
  echo "GRUB_TIMEOUT=0" | tee -a $grubConf
fi

grub-mkconfig -o /boot/grub/grub.cfg

#
# system reboot
#

echo -e "${YW}The system needs to reboot for the server to run properly. Reboot? [Y/N] ${NC}"
read bReboot
case $bReboot in
  [Yy]*)
    reboot
    ;;
  *) echo -e "${RD}aborting setup.${NC}";
esac

