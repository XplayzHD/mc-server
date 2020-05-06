# Minecraft Server
A performance-optimized portable dedicated [Minecraft](https://www.minecraft.net/) server solution for Linux

## Table of Contents
1. [Goal](#goal)
2. [Cloning](#cloning)
3. [Scratch Installation](#installation)
4. [Further Optimization](#optimization)
4. [Notes](#notes)

## Goal <a name="goal"></a>
The purpose of this project is to create a self-sufficient, portable vanilla Minecraft server on a portable Linux machine, such as a laptop. A Minecraft server run on a frequently-used machine is usually hard to manage because the host is unable to stay online 24/7, or lags significantly when run parallel to other programs. Manual backups of the server is also a prominent issue, and a lot of data can be lost due to crashes, malfunctions, or poor online ediquette from non-blacklisted users.

Keeping these issues in mind, I decided to write scripts that completely manage all of the above issues and optimize the server to its maximum potential, allowing the server full control of the memory and cpu. This solution only needs power and consistent ethernet, and backups are automatically saved.

While the scripts are intended to be used on a spare standalone machine, they can also be run in the background of a pre-existing operating system. It is important, however, that you maintain 24/7 internet access for best server network performance.
Because of this, if you would like to follow the intended route and have a machine dedicated to a Minecraft server, you can follow the [scratch installation process](#installation) to install a minimal operating system from scratch to ensure optimal performance.

I can't necessarily guarantee that my scripts will always be the most optimized for your usage. A lot of factors play a role in overall server performance but perhaps the most significant ones involves specific hardware and network connection, which these scripts cannot optimize or amend. If you still have issues running a server, see the [further optimization](#optimization) to see how to optimize server load. 

_I originally created this with a Rapsberry Pi 4 in mind but I have adjusted the guide, since a single Raspberry Pi is not sustainable for running a Minecraft server with more than two players on at once._

## Cloning <a name="cloning"></a>

1. Clone this repository into a folder of your choice. The server's settings, backups, and world save will be located in this folder. For example, if I wanted to clone these scripts into `~/minecraft`:
    ```
    git clone https://github.com/bossley9/mc-server.git minecraft
    ```
2. Run the setup script, which sets up the server as a background service.
    ```
    ./installation/setup.sh
    ```
3. Reboot the machine.
    ```
    sudo reboot
    ```
4. Make sure to OP one player once the server boots.

It's recommended you look over [further optimization](#optimization) and [notes](#notes) to see how to better manage your server.

## Scratch Installation <a name="installation"></a>

To completely wipe and install a minimal Arch distributation into the machine, see the [arch installation](installation/arch.md) guide.

## Further Optimization <a name="optimization"></a>

#### Hardware

Hardware can greatly impact the performance of a Minecraft server. As of the last time this readme was updated (2020.05.05), [Java Edition Minecraft servers handle ticks entirely with one thread](https://linustechtips.com/main/topic/824264-how-many-cores-does-a-minecraft-server-use-efficiently/). Because of this fact, the best way to optimize TPS (ticks per second) is to use a CPU with a high single-thread performance. You can find an in-depth ranking of CPU single threads [here](https://www.cpubenchmark.net/singleThread.html).

Memory could also be an issue. I recommend 8GB of RAM since Java enjoys hoarding RAM. 4GB of RAM is likely doable, but pushing the server, especially if the server is not standalone and the machine is used for casual use. I recommend using a performance utility such as `htop` or `glances` to monitor the server performance and resource usage from time to time.

## Notes <a name="notes"></a>

Significant files within the server repository is 
shown divided into the folder structure below:
```
bin/
  restart.sh
  start.sh
  stop.sh
installation/
  setup.sh
server/
  server.properties
```

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
- `backups/` - folder containing backups

By default, the server allocates 7GB of RAM for the server.

