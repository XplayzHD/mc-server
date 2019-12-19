#!/bin/bash
# script to start the server

#
# constants
#

LB='\033[1;94m'
RD='\033[1;31m'
GN='\033[1;32m'
YW='\033[1;33m'
NC='\033[0m'

EXECDIR=/usr/local/bin
ROOTDIR="$(cat $EXECDIR/minecraft/rootpath.txt)"
VERFILE=$ROOT/server.version

endpoint="$(cat $ROOTDIR/server.endpoint)"

#
# server prechecking
#

echo -e "${LB}server prechecking...${NC}"

# https://raw.githubusercontent.com/TheRemote/RaspberryPiMinecraft/master/start.sh
echo -e "\tflushing memory..."
sudo sh -c "echo 1 > /proc/sys/vm/drop_caches"
sync

echo -e "\tverifying install location..."
# sanity check
mkdir -p $ROOTDIR/backup
touch $VERFILE

echo -e "\tverifying EULA terms..."
cd $ROOTDIR
echo "eula=true" > $ROOTDIR/eula.txt

#
# getting latest vanilla version
#

echo -e "$\tgetting the latest vanilla version..."

latestVersion="$(curl https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
latestVersion=$(echo "$latestVersion" | grep -m 1 -Eo "minecraft_server[^\"]+\.jar")
latestVersion=$(echo $latestVersion | grep -Eo "[0-9]+\.[0-9]+")

echo -e "\tlatest minecraft version is ${LB}$latestVersion${NC}"

#
# check if latest version is higher than the current version
#

currentVersion="$(cat $VERFILE)"

rx='^([0-9]+\.){0,2}(\*|[0-9]+)$'
if ! [[ $currentVersion =~ $rx ]]; then currentVersion="0.0.0"; fi

#
# if latest version > current version, update current version and replace the current server
#

function versionCompare () {
  if [[ $1 == $2 ]]; then return 0; fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  
  # fill empty fields in ver1 with zeros
  for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do ver1[i]=0; done

  for ((i=0; i<${#ver1[@]}; i++)); do
    # fill empty fields in ver2 with zeros
    if [[ -z ${ver2[i]} ]]; then ver2[i]=0; fi

    if ((10#${ver1[i]} > 10#${ver2[i]})); then return 1; fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then return 2; fi
  done
  return 0
}

echo -e "\tcomparing latest version to current version..."

versionCompare $latestVersion $currentVersion

if [[ $? == 1 ]]; then # greater than means 1
  echo $latestVersion > $VERFILE
  currentVersion="$(echo $latestVerion)"

  echo -e "\tinstalling latest version..."

  link="$(curl -s https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
  link=$(echo "$link" | grep -Eo 'href="[^\"]+"' | cut -d'"' -f 2)

  curl $link -o $ROOT/server.jar
fi

#
# sending data to endpoint
#

echo -e "endpoint is [$endpoint]"
# TODO ips if endpoint exists
# echo -e "${LB}sending data to endpoint...${NC}"

# curl -s -X POST -d "ip=$ip&ipLocal=$ipLocal&status=online&mcversion=$currentVersion" $endpoint

#
# starting server
#

echo -e "\n${GN}starting server.${NC} To view server type ${LB}screen -r minecraft${NC} and to minimize the window, type ${LB}CTRL-A CTRL-D${NC}."

# allocate 2.5GB of memory maximum
screen -dmS minecraft java -Xmx2560M -Xms1024M -jar server.jar nogui

