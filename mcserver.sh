#!/bin/bash

LB='\033[1;94m'
GN='\033[1;32m'
NC='\033[0m'

# constants

ROOT="$(cat /usr/local/etc/mcserver-root)"
VER_FILE=$ROOT/server.version

# determine ips

ip="$(curl -s ifconfig.me | tr -d '[:space:]'):25565"
ipLocal="$(hostname -I | tr -d '[:space:]'):25565"

endpoint="$(cat $ROOT/server.endpoint)"

# if this is running for the first time,
# folder/file creation is required
mkdir -p $ROOT/backups
touch $VER_FILE

#
# get latest vanilla version
#

echo -e "${LB}getting the latest vanilla version...${NC}"

latestVersion="$(curl https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
latestVersion=$(echo "$latestVersion" | grep -m 1 -Eo "minecraft_server[^\"]+\.jar")
latestVersion=$(echo $latestVersion | grep -Eo "[0-9]+\.[0-9]+")

echo -e "${GN}latest minecraft version is $latestVersion${NC}"

#
# check if latest version is higher than the current version
#

currentVersion="$(cat $VER_FILE)"

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

echo -e "${LB}comparing latest version to current version...${NC}"

versionCompare $latestVersion $currentVersion

if [[ $? == 1 ]]; then # greater than means 1
  echo $latestVersion > $VER_FILE
  currentVersion="$(echo $latestVerion)"

  echo -e "${LB}installing latest version...${NC}"

  link="$(curl -s https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
  link=$(echo "$link" | grep -Eo 'href="[^\"]+"' | cut -d'"' -f 2)

  curl $link -o $ROOT/server.jar
fi

#
# start the server
#

echo -e "${LB}sending data to REST endpoint...${NC}"

curl -s -X POST -d "ip=$ip&ipLocal=$ipLocal&status=online&mcversion=$currentVersion" $endpoint

echo -e "${GN}starting server.${NC}"

cd $ROOT
echo "eula=true" > $ROOT/eula.txt
screen -dmS minecraft java -Xmx2560M -Xms1024M -jar server.jar nogui
