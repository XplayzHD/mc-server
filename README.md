# Minecraft Server
A performance-optimized portable dedicated [Minecraft](https://www.minecraft.net/) server solution

## Table of Contents
1. [Goal](#goal)
2. [Installation](#installation)
3. [Notes](#notes)

## Goal <a name="goal"></a>
The purpose of this project is to create a self-sufficient, portable Minecraft server on a portable machine, such as a laptop. A Minecraft server run on a frequently-used machine is usually hard to manage because the host is unable to stay online 24/7, or lags significantly when run parallel to other programs. Manual backups of the server is also a prominent issue, and a lot of data can be lost due to crashes, malfunctions, or poor online ediquette from non-blacklisted users.

Keeping these issues in mind, I decided to write scripts that completely manage all of the above issues and optimize the server to its maximum potential, allowing the server full control of the memory and cpu. This solution only needs power and ethernet, and backups are automatically stored.

It is important to note that the scripts I created are for a specific usage, and these conditions may not apply to you:
  - You own a spare machine (laptop, desktop, Raspberry Pi, mobile device).
  - The machine can be completely wiped and optimized for a single instance of a Minecraft server.
  - You 24/7 access to power and an ethernet connection.
  - You don't plan on using any mods and want a Vanilla Minecraft server.
Without these qualifications, I can't guarantee that my scripts will be most optimized for your usage (on a minor side note, if you make a pull request to change my scripts to work with modded servers, I would gladly review it). I also can't necessarily guarantee server performance. Because Minecraft servers only run with Java and only use a single thread, your specific CPU and RAM will factor in to the overall server performance.

_I originally created this with a Rapsberry Pi 4 in mind but I have adjusted the guide, since a single Raspberry Pi is not sustainable for running a Minecraft server with more than two players on at once._

## Installation <a name="installation"></a>

The installation involves wiping the machine completely and installing a minimal Archlinux instance. Before proceeding, make sure you have Archlinux installed according with the [Archlinux installation guide](installation/arch.md).

1. Once logged into the system, clone this repository. In this setup I'll clone it into a folder called `minecraft`:
    ```
    git clone https://github.com/bossley9/mc-server.git minecraft
    cd minecraft
    ```
2. Run the setup script.
    ```
    chmod u+x ./installation/setup.sh
    ./installation/setup.sh
    ```

    This setup process will download all necessary packages needed to optimize and run the server, as well as set up all directories and scripts. You will be prompted a few settings:
    - Enter a name for your world
    - Approve the daily server restart at 4AM local time
    At the end of the process, it will need to reboot to start the server.
    ```bash
    curl https://raw.githubusercontent.com/bossley9/mc-server/master/desktop/setup.sh -o setup.sh
    chmod +x setup.sh
    ./setup.sh
    ```
    The reason for this script is that without it, a headless server running makes it tricky to download all the specified files from this repository, unzip them and place them in the correct locations. This script makes things simpler and initializes all necessary services. Feel free to closely examine `desktop/setup.sh` for more information.
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

By default, the server allocates 7GB of RAM for the server.

