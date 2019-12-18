#!/bin/bash
# script to setup and install the server scripts

#
# constants
#

LB='\033[1;94m'
GN='\033[1;32m'
NC='\033[0m'

ROOTDIR=$HOME/.mc-server

#
# optimizing the environment
#

echo -e "${LB}optimizing the environment${NC}"

echo -e "\tdisabling bluetooth services..."
# TODO sudo systemctl stop bluetooth.service
# TODO sudo systemctl disable bluetooth.service

# https://www.instructables.com/id/Disable-the-Built-in-Sound-Card-of-Raspberry-Pi/
echo -e "\tdisabling alsa sound..."
# TODO echo -e "blacklist snd_bcm2835" | sudo tee -a /etc/modprobe.d/alsa-blacklist.conf 1>/dev/null

# https://www.cnx-software.com/2019/07/26/how-to-overclock-raspberry-pi-4/
# https://hothardware.com/reviews/hot-clocked-pi-raspberry-pi-4-benchmarked-at-214-ghz
echo -e "\tsetting up cpu overclock..."
# TODO echo -e "arm_freq=2140\nover_voltage=6" | sudo tee -a /boot/config.txt 1>/dev/null


# TODO reboot

echo "rootdir is $ROOTDIR"
