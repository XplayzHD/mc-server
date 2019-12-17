#!/bin/bash
#
# small script to manage minecraft server backups

ROOT=/home/pi/.mc-server/
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p $ROOT/backup

# create time stamp folder and copies worlds into folder
mkdir $ROOT/backup/$timestamp
cp -r $ROOT/saves/* $ROOT/backup/$timestamp/

# delete old worlds
numDir=$(ls -l | grep -c ^d)
if [[ $numDir >3 ]]
	rm -r $(ls | head -n $((numDir-3)) )
fi
