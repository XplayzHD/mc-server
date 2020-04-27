# mc-server
Scripts to optimize a dedicated [Minecraft](https://www.minecraft.net/) server solution. The scripts in this repository assume the machine the server will be hosted on can be solely dedicated to the server and nothing else. It will likely erase any of the machine's previous files and data.

## Table of Contents
1. [Goal](#goal)
2. [Setting up the hardware](#hardware)
3. [Setting up the software](#software)
3. [Setting up the Firebase endpoint (optional)](#endpoint)
4. [Setting up the server](#setup)
5. [Notes](#notes)

## Goal <a name="goal"></a>
The purpose of this project is to create a self-sufficient, portable Minecraft server on an independently controlled piece of hardware. Self-run Minecraft servers are usually hard to manage because the host's computer is unable to stay online 24/7, or, when run with other programs, slow down the server. Manually backing up the server is also a prominent issue, and a lot of data is lost due to crashes, malfunctions, or poor online ediquette from users.

With this problem in mind, I create a standalone portable Minecraft server on a machine that runs freely of any other programs, allowing the server full control of the memory and cpu. This solution only needs power and ethernet, and backups for the previous 10 days are automatically stored.

Throughout the process, I realized there is no set way of determining the ip address or status of the server without logging in and displaying from the server. I decided to use [Firebase functions](https://firebase.google.com/docs/functions) to store the server status information in a simple database and REST endpoing. A user can determine the current ip address or status of the server by visiting this Firebase endpoint. I needed to create a Firebase project for this server setup (more information in the [software section](doc/software.md)).

I initially created this guide for a Rapsberry Pi 4, but I have adjusted the guide [for other machines (desktop, laptop) as well](desktop/computer.md).

> This setup is only guaranteed to work with the hardware specified in the [hardware section](doc/hardware.md). I cannot verify these settings will work with a different Raspberry Pi model, without a heatsink, or without the specific AC power supply.

## [Setting up the hardware <a name="hardware"></a>](doc/hardware.md)

## [Setting up the software <a name="software"></a>](doc/software.md)

## [Setting up the Firebase endpoint (optional) <a name="endpoint"></a>](doc/firebase.md)

## Setting up the server <a name="setup"></a>

1. On the Raspberry Pi, run `setup.sh` from this repository to download the startup service files and server startup. This setup process will download all necessary packages needed to optimize and run the server, as well as set up all directories and scripts. You will be prompted a few settings:
    - Enter the Firebase endpoint url (optional)
    - Enter a name for your world
    - Approve the daily server restart at 4AM local time
    At the end of the process, it will need to reboot to start the server.
    ```bash
    curl https://raw.githubusercontent.com/bossley9/mc-server/master/setup.sh -o setup.sh
    chmod +x setup.sh
    ./setup.sh
    ```
    The reason for this script is that without it, a headless server running on a Raspberry Pi makes it tricky to download all the specified files from this repository, unzip them and place them in the correct locations. This script makes things simpler and initializes all necessary services. Feel free to closely examine `setup.sh` for more information.
    Your server will then be fully functional and running on reboot!
2. Before you unplug the display or disconnect the server, it is **highly recommended** that you read the [notes](#notes) and OP at least one player.

## Notes <a name="notes"></a>
A user can access the server console from the Raspberry Pi by switching processes:
```bash
sudo screen -r minecraft
```
To leave the console and switch back to the original terminal, type `CTRL+A CTRL+D`.

To OP a player (make a player an operator), type `op [username]` in the server console. Once one player is an operator, any additional operators can be added via the in-game console.

Plugging in the Pi will automatically start the server. The Pi should be connected to ethernet beforehand. 
- Navigating to the public Firebase endpoint created above will display the current server ip and status information of the server.
- When shutting down the server, it is recommended to save the world with the command `/save-all` in the Minecraft console before unplugging the Pi. There is no guarantee the server will have saved the latest updates otherwise.

The server is stored in the `~/minecraft/` directory. Various settings and properties can be changed in this folder, and on reboot, these changes will take effect. Some files to be aware of:
- `server.properties` - the main settings for the server. To change the server name, use `server.name`
- `server.name` - the name for the server
- `server.endpoint` - the REST url endpoint used by Firebase
- `backups/` - folder containing backups

By default, the server allocates 2.5GB of RAM for the server.

