#
#/bin/bash
# downloads and sets up the mc-server service.
# this script can be downloaded and run via the following command:
# curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/install.sh | sudo bash

# download startup service file into system d directory
sudo curl https://raw.githubusercontent.com/bossley9/mc-server/master/minecraftserver.service -o /etc/systemd/system/minecraftserver.service

# change permissions of file
sudo chmod 644 /etc/systemd/system/minecraftserver.service

# notify system of new service file
sudo systemctl daemon-reload
sudo systemctl start minecraftserver.service

# enable file for startup
while ! [sudo systemctl is-enabled minecraftserver == "enabled"]; do
    sudo systemctl enable minecraftserver
done

# download server execution file
sudo curl https://raw.githubusercontent.com/bossley9/mc-server/master/mcserver.sh -o /usr/local/bin/mcserver.sh

# change file permissions to allow executable
sudo chmod 754 mcserver.sh

# run server
sudo systemctl start minecraftserver.sh

