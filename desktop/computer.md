# mc-server (computer desktop/laptop)

This guide is for setting up a [Minecraft](https://www.minecraft.net/) server for a desktop or laptop computer.

## Table of Contents
3. [Setting up the software](#software)
3. [Setting up the Firebase endpoint (optional)](#endpoint)
4. [Setting up the server](#setup)
5. [Notes](#notes)

## Setting up the software <a name="software"></a>

1. Download [Arch](https://github.com/swaywm/sway/wiki). My version was 2020-01-01.
2. Burn the cd image onto a usb. This can be done via [Balena Etcher](https://www.balena.io/etcher/), [Rufus](https://rufus.ie/), or manually (Note not to include partition number):
  ```
  sudo dd bs=4M if=/path/to/iso of=/dev/sdx status=progress
  ```
3. Plug ethernet into the machine and boot from the live usb.
  - Once booted, test `ping archlinux.org` for a network response. If a response appears, skip this step. If no response appears:
    - Get the network card name.
      ```
      ip link
      ```
    - Copy the example configuration.
      ```
      cp /etc/netctl/examples/ethernet-static /etc/netctl/YOUR-NETWORK-CARD-HERE
      ```
    - Then, in `/etc/netctl/YOUR-NETWORK-CARD-HERE`:
      ```
      Interface=YOUR-NETWORK-CARD-HERE
      ```
    - Reboot with the configuration:
      ```
      netctl enable YOUR-NETWORK-CARD-HERE
      systemctl stop dhcpcd
      systemctl disable dhcpcd
      sudo reboot
      ```
    - verify `ping archlinux.org` produces a response. Do not proceed and repeat this step until a response appears.
  - Update the system time.
    ```
    timedatectl set-ntp true
    ```
  - Disk Partitioning:
    - To view disks beforehand:
      ```
      fdisk -l
      ```
    - Open the partition editor.
      ```
      cfdisk
      ```
    - Delete all partitions. Make two partitions: One for the root filesystem `/` and one for swap memory (10 GB).
      ```
      free space
      new
      ```
    - The root filesystem size will be the total size minus 10 GB.
      ```
      YOUR-FILESYSTEM-SIZE-MINUS-TEN-GIGABYTES
      primary
      bootable
      write
      ```
    - Next, the swap.
      ```
      free space
      new
      ENTER
      primary
      write
      quit
      ```
      You can verify the partition sizes with `fdisk -l`.
    - Next, overwrite any existing data and change the partition extensions.
      ```
      mkfs.etx4 /dev/sda1
      mkswap /dev/sda2
      swapon /dev/sda2
      ```
  - Mount the created root partition.
    ```
    mount /dev/sda1 /mnt
    ```  
  - Install the linux kernel and base. This will take some time to complete.
    ```
    pacstrap /mnt base linux linux-firmware
    ```
  - Generate the `fstab` and log into the root partition.
    ```
    genfstab -U /mnt >> /mnt/etc/fstab
    arch-chroot /mnt
    ```
  - Install vim (or emacs) to edit files:
    ```
    pacman -S vim vi
    ```
  - Synchronize the local time and hardware clock, where `[region]` is your region and `[city]` is your city:
    ```
    ln -sf /usr/share/zoneinfo/[region]/[city] /etc/localtime
    hwclock --systohc
    ```
  - `vim /etc/locale.gen`:
    ```
    en_US.UTF-8 UTF-8
    ```
    Then generate locales.
    ```
    locale-gen
    ```
  - `vim /etc/locale.conf` to set the system language:
    ```
    LANG=en_US.UTF-8
    ```
  - `vim /etc/hostname` to name your computer:
    ```
    YOUR-HOSTNAME-HERE
    ```
    `vim /etc/hosts` to update accordingly:
    ```
    127.0.0.1 localhost
    ::1 localhost
    127.0.1.1 YOUR-HOSTNAME-HERE.localdomain YOUR-HOSTNAME-HERE
    ```
  - Change the root password.
    ```
    passwd
    ```
  - Install and update the grub:
    ```
    pacman -S grub os-prober
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
    ```
  - Now exit, unmount the filesystem, and shutdown. Safely remove the usb after the machine is powered off.
    ```
    exit
    umount -R /mnt
    shutdown -h now
    ```
  - Power on the machine. It should boot immediately into the Arch login. If not, repeat the previous steps to install Arch.
  - Set up internet. Start by enabling ethernet network packages:
    ```
    systemctl enable systemd-networkd
    systemctl start systemd-networkd

    systemctl enable systemd-resolved
    systemctl start systemd-resolved
    ```
  - Once more, use `ip link` to get the name of the network (ethernet) card. This is usually `enp1s0` or someting similar.
    `vim /etc/systemd/network/wired.network`:
    ```
    [Match]
    Name=YOUR-NETWORK-CARD-HERE

    [Network]
    DHCP=ipv4

    [DHCP]
    RouteMetric=10
    ```
    Restart the system network daemon.
    ```
    systemctl restart systemd-networkd
    ```
  - Verify ethernet connection with `ping archlinux.org`.

## [Setting up the Firebase endpoint (optional) <a name="endpoint"></a>](doc/firebase.md)

## Setting up the server <a name="setup"></a>

1. Run `setupcomputer.sh` from this repository to download the startup service files and server startup. This setup process will download all necessary packages needed to optimize and run the server, as well as set up all directories and scripts. You will be prompted a few settings:
    - Enter the Firebase endpoint url (optional)
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

By default, the server allocates 2.5GB of RAM for the server.

