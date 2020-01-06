# mc-server (computer desktop/laptop)

This guide is for setting up a [Minecraft](https://www.minecraft.net/) server for a desktop or laptop computer.

## Table of Contents
3. [Setting up the software](#software)
3. [Setting up the Firebase endpoint (optional)](#endpoint)
4. [Setting up the server](#setup)
5. [Notes](#notes)

## Setting up the software <a name="software"></a>

1. Go to [https://ubuntu.com/download/server](https://ubuntu.com/download/server) to download the latest Ubuntu 64-bit server, unzip it, and write the `iso` image to a flash drive. I used (and recommend) [BalenaEtcher](https://www.balena.io/etcher/) to write the image; however, you can use other methods such as [Rufus](https://rufus.ie/), or by manually writing to the drive with the `dd` command. 
The latest version for me was 18.04 LTS.

2. Connect the usb to the computer. In the bios screen, choose the usb. You may need to enable `legacy mode` in order to boot from the usb.

3. Eventually terminal output will come to a stop, and it will prompt for a username and password. Set your username and password.

## [Setting up the Firebase endpoint (optional) <a name="endpoint"></a>](doc/firebase.md)

## Setting up the server <a name="setup"></a>

1. Run `setupcomputer.sh` from this repository to download the startup service files and server startup. This setup process will download all necessary packages needed to optimize and run the server, as well as set up all directories and scripts. You will be prompted a few settings:
    - Enter the Firebase endpoint url (optional)
    - Enter a name for your world
    - Approve the daily server restart at 4AM local time
    At the end of the process, it will need to reboot to start the server.
    ```bash
    curl https://raw.githubusercontent.com/bossley9/mc-server/master/setupcomputer.sh -o setup.sh
    chmod +x setup.sh
    ./setup.sh
    ```
    The reason for this script is that without it, a headless server running on a Raspberry Pi makes it tricky to download all the specified files from this repository, unzip them and place them in the correct locations. This script makes things simpler and initializes all necessary services. Feel free to closely examine `setupcomputer.sh` for more information.
    Your server will then be fully functional and running on reboot!
2. Before you unplug the display or disconnect the server, it is **highly recommended** that you read the [notes](#notes) and OP at least one player.

## Notes <a name="notes"></a>
A user can access the server console from the computer by switching processes:
```bash
sudo screen -r minecraft
```
To leave the console and switch back to the original terminal, type `CTRL+A CTRL+D`.

To OP a player (make a player an operator), type `op [username]` in the server console. Once one player is an operator, any additional operators can be added via the in-game console.

Turning on the computer will automatically start the server. The computer should be connected to ethernet beforehand. 
- Navigating to the public Firebase endpoint created above will display the current server ip and status information of the server.
- When shutting down the server, it is recommended to save the world with the command `/save-all` in the Minecraft console before unplugging the computer. There is no guarantee the server will have saved the latest updates otherwise.

The server is stored in the `~/minecraft/` directory. Various settings and properties can be changed in this folder, and on reboot, these changes will take effect. Some files to be aware of:
- `server.properties` - the main settings for the server. To change the server name, use `server.name`
- `server.name` - the name for the server
- `server.endpoint` - the REST url endpoint used by Firebase
- `backups/` - folder containing backups

By default, the server allocates 2.5GB of RAM for the server.

