# mc-server
A portable server solution for [Minecraft](https://www.minecraft.net/)

## Table of Contents
1. [Goal](#goal)
2. [Hardware](doc/hardware.md)
3. [Software](doc/software.md)
4. [Setup](#setup)

## Goal <a name="goal"></a>
The purpose of this project is to create a self-sufficient portable Minecraft server on an independently controlled piece of hardware. Modern Minecraft servers are usually hard to manage because the host server is unable to stay online 24/7, or, when run with other programs, slow down the server. Backing up is also a prominent issue, and a lot of data is lost due to crashes, malfunctions, or poor online ediquette from users.

With this solution, I hope to create a standalone portable server that runs freely of any other programs, allowing the server full control of the memory and cpu. This standalone solution only needs power and internet, and backups for the previous 3 weeks will stored (one backup per week).

Throughout the process, I realized there is no set way of determining the ip address or status of the server. I decided to use [Firebase functions](https://firebase.google.com/docs/functions) to store the server status information in a simple database. An end-user can determine the current ip address or status of the server by visiting this Firebase endpoint. Thus, you will need to create a Firebase project to run this server setup (more information in the [software section](doc/software.md)).

> These settings are only guaranteed to work with the hardware setup specified in the [hardware section](doc/hardware.md). I cannot verify these settings will work with a different Raspberry Pi model, no heatsink, or without the specific power supply.

## Usage <a name="usage"></a>

1. [optional] Setup a Firebase project to run this server. More detailed instructions can be found in [doc/firebase.md](doc/firebase.md).
2. On the Raspberry Pi, run `install.sh` from this repository to download the startup service files and server startup. Enter the endpoint url in the command. This will connect your server to the database.
    ```bash
    curl -s https://raw.githubusercontent.com/bossley9/mc-server/rework/setup.sh -o setup.sh
    chmod 755 setup.sh
    ./setup.sh
    ```
    The reason for this script is that without it, a headless Ubuntu server running on a Raspberry Pi makes it tricky to download all the specified files from this repository, unzip them and place them in the correct locations. This script makes things simpler and initializes all necessary services. Feel free to closely examine `install.sh` for more information.
    The endpoint is saved under `YourHomeDirectory/.mc-server/server.endpoint`. Usually this is `/home/pi/.mc-server/server.endpoint`. You may update the endpoint in the future, and a restart of the server will be required for the new endpoint to take effect.
      
      > By default, the server executable allocates 2.5GB of RAM for the server.

    After reboot, the server will be fully functional!
    A user can access the server by changing to root and changing screens:
    ```bash
    su -
    screen -r minecraft
    ```
    It is recommended to OP at least one player via the server console once it starts up:
    ```
    op [username]
    ```
    To detatch the screen, type CTRL-A CTRL-D

- Plugging in the Pi will automatically start the server. The Pi should be connected to ethernet beforehand. 
- Navigating to the public Firebase endpoint created above will display the current server ip and status information of the server.
- When shutting down the server, it is recommended to save the world with the command `/save-all` in the Minecraft console before unplugging the Pi. There is no guarantee the server will have saved the latest updates otherwise.

