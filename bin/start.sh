#!/bin/sh
# script to start the server

#
# constants
#

LB='\033[1;94m'
RD='\033[1;31m'
GN='\033[1;32m'
YW='\033[1;33m'
NC='\033[0m'

EXECDIR="/usr/local/bin"
ROOTDIR="$(cat $EXECDIR/minecraft/rootpath.txt)"
VERFILE="$ROOTDIR/server.version"
numBackups=10

# store server ip addresses

echo "$(ip a | awk '/state UP/{getline; getline; print $2}' | cut -d '/' -f1)" | tee $ROOTDIR/server.ip
echo "$(curl -S ifconfig.me)" | tee -a $ROOTDIR/server.ip

#
# precheck
#

# set saves folder
mkdir -p $ROOTDIR/saves
serverProps=$ROOTDIR/server.properties

#
# backing up server
#

echo -e "${LB}backing up server...${NC}"
# sanity check
mkdir -p $ROOTDIR/backups
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

# copy worlds into timestampped folder
mkdir -p  $ROOTDIR/backups/$timestamp
cp -r $ROOTDIR/saves/* $ROOTDIR/backups/$timestamp/ > /dev/null

# delete old worlds
numDirectories=$(ls -l | grep -c ^d)
if [[ $numDirectories > $numBackups ]]; then
  ls -tp | grep -v '/$' | tail -n +$numBackups | xargs -I {} rm -- {}
fi

#
# server prechecking
#

echo -e "${LB}server prechecking...${NC}"

echo -e "\tflushing memory..."
sh -c "echo 1 > /proc/sys/vm/drop_caches"
sync

echo -e "\tverifying install location..."
touch $VERFILE

#
# getting latest vanilla version
#

echo -e "\tgetting the latest vanilla version..."

latestVersion="$(curl https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
latestVersion=$(echo "$latestVersion" | grep -m 1 -Eo "minecraft_server[^\"]+\.jar")
latestVersion=$(echo $latestVersion | grep -Eo "[0-9]+\.[0-9]+(\.[0-9]+)?")

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

  link="$(curl https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
  link=$(echo "$link" | grep -Eo 'href="[^\"]+"' | cut -d'"' -f 2)

  curl $link -o $ROOTDIR/server.jar
fi

#
# starting server
#

echo -e "\n${GN}starting server.${NC} To view server from root, type ${LB}screen -r minecraft${NC}. To minimize the window, type ${LB}CTRL-A CTRL-D${NC}."

cd $ROOTDIR
nice -n -20 screen -dmS minecraft java -server -Xmx4G -Xms1G -jar $ROOTDIR/server.jar nogui
