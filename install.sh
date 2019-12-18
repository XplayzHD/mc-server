#/bin/bash

LB='\033[1;94m'
GN='\033[1;32m'
NC='\033[0m'

ROOT="$(echo $HOME/.mc-server)"

#
# server startup service
#

echo -e "${LB}downloading the server startup service from the repository...${NC}"

sudo curl https://raw.githubusercontent.com/bossley9/mc-server/master/minecraftserver.service -o /etc/systemd/system/minecraftserver.service
sudo chmod 644 /etc/systemd/system/minecraftserver.service

sudo systemctl daemon-reload

echo -e "${LB}enabling the server startup service...${NC}"

while ! [[ $(sudo systemctl is-enabled minecraftserver) == "enabled" ]]; do
  sudo systemctl enable minecraftserver
done

echo -e "${GN}server startup service is now enabled.${NC}"

#
# server directory
#

echo -e "${LB}setting up server directory...${NC}"

mkdir -p $ROOT

echo -e "${LB}storing data endpoint...${NC}"

touch $ROOT/dataEndpoint.txt # sanity check
echo $1 > $ROOT/dataEndpoint.txt

echo -e "${GN}server directory initialized.${NC}"

#
# server executable
#

echo -e "${LB}downloading server executable...${NC}"

sudo curl https://raw.githubusercontent.com/bossley9/mc-server/master/mcserver.sh -o /usr/local/bin/mcserver.sh
sudo chmod 754 /usr/local/bin/mcserver.sh

echo -e "${GN}server executable initialized.${NC}"

#
# save backups
#

echo -e "${LB}downloading save backup executable...${NC}"

sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/mcserverbackup.sh -o /usr/local/bin/mcserverbackup.sh
sudo chmod 754 /usr/local/bin/mcserverbackup.sh

echo -e "${LB}installing backup function...${NC}"

sudo apt-get install anacron
# replace default anacron file with modified version
sudo curl https://raw.githubusercontent.com/bossley9/mc-server/master/anacrontab -o /etc/anacrontab

#
# start server
#

echo -e "${GN}finished!${NC}"
echo -e "${LB}starting server...${NC}"

sudo /usr/local/bin/./mcserver.sh

