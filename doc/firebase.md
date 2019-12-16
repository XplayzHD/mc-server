## Firebase setup
This document provides detailed instructions on how to configure a Firebase project to display the ip address and log info of the server. These steps will create a RESTful API endpoint. In order to run and deploy Firebase functions, you will need to use [npm](https://www.npmjs.com/get-npm) to download [firebase-tools](https://github.com/firebase/firebase-tools).

Since cloud functions are not hosted by the Pi, the setup and installation of the functions can be run on a different machine.

Node and npm can be installed by running the following commands in Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install nodejs
```

Then install `firebase-tools` globally:
```bash
npm i -g firebase-tools
```

1. Create a [new Firebase project](https://console.firebase.google.com/).
2. Login to Firebase.
    ```bash
    firebase login
    ```
3. In the directory of your choice, download the Firebase functions using the `firebase.sh` script. This script will create a folder called `mcserver-functions` in your current directory, containing the functions necessary to display the status, then proceed to upload these functions to the cloud. You may need to specify in the command line which Firebase project you would like to use. Select the project you just created.
    ```bash
      curl -s https://raw.githubusercontent.com/bossley9/mc-server/master/firebase.sh | sudo bash
    ```
4. Go to the [Firebase console](https://console.firebase.google.com/) and select your project. In the side panel on the left, select `Functions`. The url displayed will be the url endpoint for your server. Open this url in a browser. When the server is active, the server will display the ip and status information at this url.

    Save this url endpoint.

