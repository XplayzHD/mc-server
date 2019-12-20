# script to stop the server

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
# precheck
#

# verify server is running
if ! screen -list | grep -q "minecraft"; then
  echo -e "${RD}server is not currently running (invalid stop)${NC}"
  exit 1
fi

#
# stop
#

echo -e "${LB}stopping the server...${NC}"

screen -Rd minecraft -X stuff "say closing server manually.$(printf '\r')"
screen -Rd minecraft -X stuff "stop$(printf '\r')"

#
# sending data to endpoint
#

endpoint="$(cat $ROOTDIR/server.endpoint)"
if ! [ -z "$endpoint" ]; then
  echo -e "${LB}sending data to endpoint...${NC}"
  
  ip="$(curl -s ifconfig.me | tr -d '[:space:]'):25565"
  ipLocal="$(hostname -I | tr -d '[:space:]'):25565"

  curl -s -X POST -d "ip=$ip&ipLocal=$ipLocal&status=offline&message=shutdown" $endpoint
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

echo -e "${GN}server stopped.${NC}"
sync
