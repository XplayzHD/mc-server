# mc-server
A portable server solution for [Minecraft](https://www.minecraft.net/)

## Table of Contents
1. [Goal](#goal)
2. [Hardware](doc/hardware.md)
3. [Software](doc/software.md)
4. [Usage](#usage)

## Goal <a name="goal"></a>
The purpose of this project is to create a self-sufficient portable Minecraft server on an independently controlled piece of hardware. Modern Minecraft servers are usually hard to manage because the host server is unable to stay online 24/7, or, when run with other programs, slow down the server. Backing up is also a prominent issue, and a lot of data is lost due to crashes, malfunctions, or poor online ediquette from users.

With this solution, I hope to create a standalone portable server that runs freely of any other programs, allowing the server full control of the memory and cpu. This standalone solution only needs power and internet, and backups for the previous 3 weeks will stored (one backup per week).

Throughout the process, I realized there is no set way of determining the ip address or status of the server. I decided to use [Firebase functions](https://firebase.google.com/docs/functions) to store the server status information in a simple database. An end-user can determine the current ip address or status of the server by visiting this Firebase endpoint. Thus, you will need to create a Firebase project to run this server setup (more information in the [software section](doc/software.md)).

> These settings are only guaranteed to work with the hardware setup specified in the [hardware section](doc/hardware.md). I cannot verify these settings will work with a different Raspberry Pi model, no heatsink, or without the specific power supply.

## Usage <a name="usage"></a>

1. Install Java 8 JDK.
    ```bash
    sudo apt-get update
    sudo apt-get install openjdk-8-jre-headless
    ```
    You can verify installation with `java -version`.
2. You will need to setup a Firebase project to run this server. More detailed instructions can be found in [doc/firebase.md](doc/firebase.md).
3. Before proceeding to this step, make sure you have the Firebase API endpoint url handy. On the Pi server, run `install.sh` from this repository to download the startup service files and server startup. Enter the endpoint url in the command. This will connect your server to the database.
    ```bash
    curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/install.sh -o install.sh
    chmod 755 install.sh
    ./install.sh [FirebaseEndpointUrl]
    ```
    The reason for this script is that without it, a headless Ubuntu server running on a Raspberry Pi makes it tricky to download all the specified files from this repository, unzip them and place them in the correct locations. This script makes things simpler and initializes all necessary services. Feel free to closely examine `install.sh` for more information.
    The endpoint is saved under `YourUserHomeDirectory/.mc-server/server.endpoint`. Usually this is `/home/pi/.mc-server/server.endpoint`. You may update the endpoint in the future, and a restart of the server will be required for the new endpoint to take effect.
      
      > By default, the `mcserver.sh` executable allocates 2.5GB of RAM for the server. Depending on the Pi being used, these settings can be changed in `mcserver.sh`.

    Once all necessary files are downloaded and in place, the server will begin to run. It is recommended to OP at least one player via the server console once it starts up:
    ```
    op [username]
    ```
    Then stop the server.
    ```
    stop
    ```
4. Open the file `server.properties` in the `.mc-server` folder and change `level-name: world` to `level-name: saves/WorldNameHere` This allows the backup script to access the correct files.
5. Restart the Pi by unplugging and replugging the Pi. The server should now be fully functional.

- Plugging in the Pi will automatically start the server. The Pi should be connected to ethernet beforehand. 
- Navigating to the public Firebase endpoint created above will display the current server ip and status information of the server.
- When shutting down the server, it is recommended to save the world with the command `/save-all` in the Minecraft console before unplugging the Pi. There is no guarantee the server will have saved the latest updates otherwise.

