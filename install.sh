#
#/bin/bash
# downloads and sets up the mc-server service.
# this script can be downloaded and run via the following command:
# curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/install.sh | sudo bash

#
# 1. Setup startup server function
#

echo "downloading startup service..."

# download startup service file into system d directory
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/minecraftserver.service -o /etc/systemd/system/minecraftserver.service

# change permissions of file
sudo chmod 644 /etc/systemd/system/minecraftserver.service

# notify system of new service file
sudo systemctl daemon-reload
sudo systemctl start minecraftserver.service

# enable file for startup
while ! [[ $(sudo systemctl is-enabled minecraftserver) == "enabled" ]]; do
    sudo systemctl enable minecraftserver
done

#
# 2. Install server executable
#

# download server execution file
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/mcserver.sh -o /usr/local/bin/mcserver.sh

ROOT=~/.mc-server

read -p "$(echo -e "Please specify the Firebase API endpoint you would like to use: ")" urlEndpoint
echo $urlEndpoint > $ROOT/firebaseEndpoint.txt

# change file permissions to allow executable
sudo chmod 754 /usr/local/bin/mcserver.sh

#
# 3. Setup save file backups
#

# download saves backup file
sudo curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/mcserverbackup.sh -o /usr/local/bin/mcserverbackup.sh

# change file permissions to allow executable
sudo chmod 754 /usr/local/bin/mcserverbackup.sh

# install anacron for weekly backups
sudo apt-get install anacron

# replaces default anacron file with modified version
sudo curl https://raw.githubusercontent.com/bossley9/mc-server/master/anacrontab -o /etc/anacrontab

#
# 4. Start Server
#

# run server
sudo systemctl start minecraftserver.sh

