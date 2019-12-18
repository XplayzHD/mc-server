#/bin/bash

LB='\033[1;94m'
GN='\033[1;32m'
NC='\033[0m'

ROOT="$(echo $HOME/.mc-server)"

#
# optimizing environment
#

echo -e "${LB}optimizing environment...${NC}"

echo -e "${LB}disabling bluetooth...${NC}"
sudo service bluetooth stop

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

# since redirection is executed by the shell, use tee for sudo privileges

echo -e "${LB}saving root directory...${NC}"
echo $ROOT | sudo tee /usr/local/etc/mcserver-root > /dev/null

echo -e "${LB}storing data endpoint...${NC}"
echo $1 | sudo tee $ROOT/server.endpoint > /dev/null

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

