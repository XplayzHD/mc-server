## Software <a name="software"></a>

The steps below are the steps I followed to setup up the Raspberry Pi.

1. Go to [https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/) to download Raspbian Buster Lite 64-bit, unzip it, and put the image on the microSD card. I used (and recommend) [BalenaEtcher](https://www.balena.io/etcher/) to write the image to the SD card.

2. Connect the SD card, display, and keyboard to the Pi. Connect an ethernet cable to the back of the modem, or router. Finally, connect power. One of the power lights will be red whilst the other blinks green periodically (signifiying that it is reading the SD card).
    Note that the Pi must be connected to a display _first_ before the power. If it is not connected to a display at boot time, it will not attempt to display after that.
3. Eventually terminal output will come to a stop, and it will prompt for a username and password (in my case, it printed dmesg info after it prompted for a username). Enter `pi` for the username and `raspberry` for the password. You will want to change the password.
    ```bash
    passwd
    ```

See [hardware](hardware.md).
See [usage](../README.md).
