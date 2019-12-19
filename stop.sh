#!/bin/bash
# script to stop the server

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
# stop
#

echo -e "${LB}stopping the server...${NC}"

screen -Rd minecraft -X stuff "say closing server manually.$(printf '\r')"
screen -Rd minecraft -X stuff "stop$(printf '\r')"

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

echo "${GN}server stopped.${NC}"
sync
