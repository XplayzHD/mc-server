#!/bin/bash
# script to restart the server

#
# constants
#

LB='\033[1;94m'
RD='\033[1;31m'
GN='\033[1;32m'
NC='\033[0m'

#
# precheck
#

# verify server is running
if ! screen -list | grep -q "minecraft"; then
  echo -e "${RD}server is not currently running. Invalid restart.${NC}"
  exit 1
fi

#
# countdown
#

screen -Rd minecraft -X stuff "say server will restart in 1 minute.$(printf '\r')"
sleep 30s
screen -Rd minecraft -X stuff "say server will restart in 30 seconds.$(printf '\r')"
sleep 15s
screen -Rd minecraft -X stuff "say server will restart in 15 seconds.$(printf '\r')"
sleep 5s
screen -Rd minecraft -X stuff "say server will restart in 10 seconds.$(printf '\r')"
sleep 5s
screen -Rd minecraft -X stuff "say server will restart in 5 seconds.$(printf '\r')"
sleep 5s

screen -Rd minecraft -X stuff "say closing server.$(printf '\r')"
screen -Rd minecraft -X stuff "stop$(printf '\r')"

# wait 30 seconds for server to close

echo -e "${LB}closing server...${NC}"

StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "minecraft"; then break; fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

echo "${GN}restarting.${NC}"
sudo reboot
