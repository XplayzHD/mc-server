# Minecraft Server
A performance-optimized portable dedicated [Minecraft](https://www.minecraft.net/) server solution for Linux

## Table of Contents
1. [Goal](#goal)
2. [Cloning](#cloning)
3. [Scratch Installation](#installation)
4. [How Can I Find My Server IP?](#ip)
5. [Further Optimization](#optimization)
6. [Notes](#notes)

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
    If you would like to further optimize the system, check out [further optimization](#optimization).
3. Reboot the machine. Make sure to OP one player once the server boots.
    ```
    sudo reboot
    ```
I recommended you look over [notes](#notes) to see how to better manage your server.

## Scratch Installation <a name="installation"></a>

To completely wipe and install a minimal Arch distributation into the machine, see the [arch installation](installation/arch.md) guide.

## How Can I Find My Server IP? <a name="ip"></a>

The local and broadcasted server ips will be generated every time the server starts 
in `server/server.ip`. The first line will correspond to the IP address in the local network, and the second IP corresponds to the broadcasted IP address for anyone to use.

Note that the broadcasted address will not work unless the local network's port `25565` is port-forwarded. The process is different depending on the modem and internet service provider you use, but generally they all involve opening the modem's settings browser page and adding `25565` to the port-forward section.

## Further Optimization <a name="optimization"></a>

- [Hardware](#op-hardware)
- [Laptop Lid](#op-lid)
- [CPU Performance Governor](#op-governor)

#### Hardware <a name="op-hardware"></a>

Hardware can greatly impact the performance of a Minecraft server. As of the last time this readme was updated (2020.05.05), [Java Edition Minecraft servers handle ticks entirely with one thread](https://linustechtips.com/main/topic/824264-how-many-cores-does-a-minecraft-server-use-efficiently/). Because of this fact, the best way to optimize TPS (ticks per second) is to use a CPU with a high single-thread performance. You can find an in-depth ranking of CPU single threads [here](https://www.cpubenchmark.net/singleThread.html).

Memory could also be an issue. I recommend 8GB of RAM since Java enjoys hoarding RAM. 4GB of RAM is likely doable, but pushing the server, especially if the server is not standalone and the machine is used for casual use. I recommend using a performance utility such as `htop` or `glances` to monitor the server performance and resource usage from time to time.

#### Laptop Lid <a name="op-lid"></a>

If you plan on running a server with a laptop and don't want to have the lid turn of or suspend the server every time it it closed, you can disabled the laptop lid from affecting the power management by editing `/etc/systemd/logind.conf` and altering the following lines:
```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

#### CPU Performance Governor <a name="op-governor"></a>

Most Linux systems come with a scaling governor which determines how intensive a CPU should run to match its load. By default, it chooces `on demand`, meaning it scales based on how much CPU is required by running programs. It is possible to improve server performance on a machine by setting the scaling governor to `performance`, to run at max performance regardless of running programs.
```
echo "performance" | tee "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" >/dev/null 2>&1 
```

## Notes <a name="notes"></a>

After the initial restart, turning on the host machine will automatically start 
the server. It is a good idea to connect the machine to internet beforehand.

A user with sudo privileges can access the server console from the machine 
through the `screen` program:
```bash
sudo screen -r minecraft
```
To leave the server console screen and switch back to the original terminal, type `CTRL + a CTRL + d`.

To OP a player (make a player an operator), type `op [username]` in the server console. 
Once a single player is an operator, any additional operators can be added via the 
in-game console with the same command.

The server will automatically restart once every 24 hours at 4 AM (local time).
You can also manually control starting and stopping the server manually with 
`systemctl` commands such as `sudo systemctl stop minecraft` 
and `sudo systemctl start minecraft`.

By default, the server allocates 4GB of RAM for the server.

The actual server portion of the scripts is stored in the `server/` directory.
Significant files within the folder are shown below:
```
server/
  backups/
  saves/
  server.properties
  server.ip
```

- `backups` - the backups folder stores the previous ten backups from the server
- `saves` - holds the current server save file. Be careful not to tamper or 
          delete anything in this folder, and risk losing your server!
- `server.properties` - holds all minecraft server settings in key-value pairs.
          change settings to your liking here. The server will need to restart 
          before settings can go into effect.
- `server.ip` - holds local and broadcasted server IPs. This is only generated 
          once the server is started.
