# mc-server
A portable server solution for [Minecraft](https://www.minecraft.net/)

## Table of Contents
1. [Goal](#goal)
2. [Hardware](#hardware)
3. [Software](#software)
4. [Usage](#usage)

## Goal <a name="goal"></a>
The purpose of this project is to create a self-sufficient portable Minecraft server on an independently controlled piece of hardware. Modern Minecraft servers are usually hard to manage because the host server is unable to stay online 24/7, or, when run with other programs, slow down the server. Backing up is also a prominent issue, and a lot of data is lost due to crashes, malfunctions, or poor online ediquette from users.

With this solution, I hope to create a standalone portable server that runs freely of any other programs, allowing the server full control of the memory and cpu. This standalone solution only needs power and internet, and backups for the previous 3 weeks will stored (one backup per week).

Throughout the process, I realized there is no set way of determining the ip address or status of the server. I decided to use [Firebase functions](https://firebase.google.com/docs/functions) to store the server status information in a simple database. An end-user can determine the current ip address or status of the server by visiting this Firebase endpoint. Thus, you will need to create a Firebase project to run this server setup (more information in the [software section](#software)).

## Hardware <a name="hardware"></a>

The server hardware consists of the following products. Including tax, the total cost was around $135.

> Note that this list of products does not include an ethernet cable or an HDMI display, both of which I already owned.

> I also purchased a standard Raspberry Pi Black Case for $5, which, to my dismay, does not fit the heat sink.

- [Raspberry Pi 4 Computer Model B (4GB RAM)](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/) - $50
  
  <img src="doc/raspberrypi.jpg" alt="Raspberry Pi" width="500px" />

- Raspberry Pi USB-C Power Supply - $8

  <img src="doc/power.jpg" alt="power cable" width="500px" />

- Adafruit [4340] Aluminum Metal Heatsink Raspberry Pi 4 Case with Dual Fans - $25

  <img src="doc/heatsink.jpg" alt="heat sink" width="500px" />

- Raspberry Pi Micro HDMI Cable - $9

  <img src="doc/adapter.jpg" alt="adapter" width="500px" />

- Verbatim microSDXC With Adapter (64GB) - $9

  <img src="doc/sd.jpg" alt="sd" width="500px" />

- Logitech K400 Wireless Touch Keyboard - $20

  <img src="doc/keyboard.jpg" alt="keyboard" width="500px" />

The steps below are the steps I followed to setup up the Raspberry Pi.

1. Screw the fans down into the heat sink. It's important to notice that there are two types of screws. The flatter-head screws are used to attach the fans to the heat sink.

2. Place the thermal pads on the cpu.

    <img src="doc/thermal.jpg" alt="thermal pads" width="500px" />

3. Screw the heat sink and the base into the Pi. The fan pins connect to power and ground, respectively.

    <img src="doc/sinkandpi.jpg" alt="heat sink and pi" width="500px" />
    <img src="doc/pinlayout.jpg" alt="pin layout diagram" width="500px" />

## Software <a name="software"></a>

The steps below are the steps I followed to setup up the operating system, backups, and start the server.

> You will need sudo privileges to download the following files and enable the startup service. 

1. Go to [https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/) to download Raspbian Buster Lite 64-bit, unzip it, and put the image on the microSD card. I used (and recommend) [BalenaEtcher](https://www.balena.io/etcher/) to write the image to the SD card.

2. Connect the SD card, display, and keyboard to the Pi. Connect an ethernet cable to the back of the modem, or router. Finally, connect power. One of the power lights will be red whilst the other blinks green periodically (signifiying that it is reading the SD card).
    I had a few issues with the TV display not detecting the Pi. After disconnecting and reconnecting both the power and display cables, it seems to have booted and displayed on the screen.
3. Eventually terminal output will come to a stop, and it will prompt for a username and password (in my case, it printed some dmesg info after it prompted for my username). Enter `pi` for the username and 'raspberry' for the password. You may want to change the password.
    ```bash
    passwd
    ```
4. Install Java 8 JDK.
    ```bash
    sudo apt-get update
    sudo apt-get install openjdk-8-jre-headless
    ```
    You can verify installation with `java -version`.
5. You will need to setup a Firebase project to run this server. More detailed instructions can be found in [doc/firebase.md](doc/firebase.md).
6. Before proceeding to this step, make sure you have the Firebase API endpoint url handy. On the Pi server, run `install.sh` from this repository to download the startup service files and server startup. Enter the endpoint url in the command. This will connect your server to the database.
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
7. Open the file `server.properties` in the `.mc-server` folder and change `level-name: world` to `level-name: saves/WorldNameHere` This allows the backup script to access the correct files.
8. Restart the Pi by unplugging and replugging the Pi. The server should now be fully functional.

## Usage <a name="usage"></a>

- Plugging in the Pi will automatically start the server. The Pi should be connected to ethernet beforehand. 
- Navigating to the public Firebase endpoint created above will display the current server ip and status information of the server.
- When shutting down the server, it is recommended to save the world with the command `/save-all` in the Minecraft console before unplugging the Pi. There is no guarantee the server will have saved the latest updates otherwise.

