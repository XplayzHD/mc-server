#
#/bin/bash
# downloads and sets up the mc-server service.
# this script can be downloaded and run via the following command:
# curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/install.sh | sudo bash

# download startup service file
curl https://raw.githubusercontent.com/bossley9/mc-server/master/minecraftserver.service

# change permissions of file
chmod 644 minecraftserver.service

# move startup service file to systemd directory
sudo mv -v ./minecraftserver.service /etc/systemd/system/


# notify system of new service file
sudo systemctl daemon-reload
sudo systemctl start minecraftserver.service

# enable file for startup
while ! [sudo systemctl is-enabled minecraftserver == "enabled"]; do
    sudo systemctl enable minecraftserver
done

# download server execution file
curl https://raw.githubusercontent.com/bossley9/mc-server/master/mcserver.sh

# change file permissions
chmod 744 mcserver.sh

# run server
./mc-server.sh
