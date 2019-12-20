## Software <a name="software"></a>

Below are the steps to setup up the Raspberry Pi.

1. Go to [https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/) to download Raspbian Buster Lite 64-bit, unzip it, and put the image on the microSD card. I used (and recommend) [BalenaEtcher](https://www.balena.io/etcher/) to write the image to the SD card.

2. Connect the SD card, display, and keyboard to the Pi. Connect an ethernet cable to the back of the modem, or router. Finally, connect power. _Note that the Pi must be connected to a display **first** before the power. If it is not connected to a display at boot time, it will not attempt to display after that._ When on, two lights will display - a red light and a green light. The red light signifies power whilst the green light signifies that it is reading the SD card.
3. Eventually terminal output will come to a stop, and it will prompt for a username and password (in my case, it printed dmesg info after it prompted for a username). Enter `pi` for the username and `raspberry` for the password. You will want to change the password before continuing.
    ```bash
    passwd
    ```
