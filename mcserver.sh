#!/bin/bash
# this script will run on startup.

ROOT=~/.mc-server
verFile=$ROOT/server.version
ip="$(hostname -I | tr -d '[:space:]'):25565"
endpoint="$(cat $ROOT/firebaseEndpoint.txt)"

# if this is running for the first time,
# folder/file creation is required
mkdir -p $ROOT/backups
touch $verFile

#
# 1. get latest vanilla version number
#

latestVersion="$(curl --silent https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
latestVersion=$(echo "$latestVersion" | grep -m 1 -Eo "minecraft_server[^\"]+\.jar")
latestVersion=$(echo $latestVersion | grep -Eo "[0-9]+\.[0-9]+")

#
# 2. check if latest version is higher than the current version
#

currentVersion="$(cat $verFile)"

rx='^([0-9]+\.){0,2}(\*|[0-9]+)$'
if ! [[ $currentVersion =~ $rx ]]; then
  currentVersion="0.0.0" 
fi

#
# 3. if latest version > current version, update current version and replace the current server
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

versionCompare $latestVersion $currentVersion

if [[ $? == 1 ]]; then # greater than means 1
  echo $latestVersion > $verFile 
  currentVersion=$latestVerion

  link="$(curl --silent https://www.minecraft.net/en-us/download/server/ | grep -e 'minecraft_server')"
  link=$(echo "$link" | grep -Eo 'href="[^\"]+"' | cut -d'"' -f 2)

  curl $link -o $ROOT/server.jar
fi

#
# 4. start the server
#

curl --silent -X POST -d "ip=$ip&status=online&mcversion=$currentVersion" $endpoint

cd $ROOT
echo "eula=true" > $ROOT/eula.txt
java -Xmx2048M -Xms1024M -jar server.jar nogui
