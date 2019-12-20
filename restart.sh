#!/bin/bash
# script to restart the server

#
# constants
#

LB='\033[1;94m'
RD='\033[1;31m'
GN='\033[1;32m'
NC='\033[0m'

EXECDIR="/usr/local/bin"
ROOTDIR="$(cat $EXECDIR/minecraft/rootpath.txt)"

#
# precheck/countdown
#

# verify server is running
if ! sudo screen -list | grep -q "minecraft"; then
  echo -e "${RD}server is not currently running (invalid restart)${NC}"
else
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

  screen -Rd minecraft -X stuff "say closing server$(printf '\r')"
  screen -Rd minecraft -X stuff "stop$(printf '\r')"
fi

#
# sending data to endpoint
#

endpoint="$(cat $ROOTDIR/server.endpoint)"
if ! [ -z "$endpoint" ]; then
  echo -e "${LB}sending data to endpoint...${NC}"
  
  ip="$(curl -s ifconfig.me | tr -d '[:space:]'):25565"
  ipLocal="$(hostname -I | tr -d '[:space:]'):25565"

  curl -s -X POST -d "ip=$ip&ipLocal=$ipLocal&status=offline&message=restarting" $endpoint
fi

# wait 30 seconds for server to close

echo -e "${LB}closing server...${NC}"

StopChecks=0
while [ $StopChecks -lt 30 ]; do
  if ! screen -list | grep -q "minecraft"; then break; fi
  sleep 1;
  StopChecks=$((StopChecks+1))
done

if screen -list | grep -q "minecraft"; then
  echo -e "${RD}server is still open, closing manually${NC}"
  screen -S minecraft -X quit
fi

echo -e "${GN}restarting.${NC}"
sudo reboot
