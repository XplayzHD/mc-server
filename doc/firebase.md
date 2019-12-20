## Firebase setup
This document provides detailed instructions on how to configure a Firebase project to display the ip address and status info of the server. These steps will create a RESTful API endpoint. In order to run and deploy Firebase functions, you will need to use [npm](https://www.npmjs.com/get-npm) to download [firebase-tools](https://github.com/firebase/firebase-tools).

This process can be done on a different computer.

Node and npm can be installed by running the following commands in Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install nodejs
```
If these commands do not work, see [other options for installation](https://nodejs.org/en/download/).

Then install `firebase-tools` globally:
```bash
npm i -g firebase-tools
```

1. Create a [new Firebase project](https://console.firebase.google.com/).
2. Login to Firebase.
    ```bash
    firebase login
    ```
3. In the directory of your choice, initialize a functions project. When prompted, choose functions and continue, use the project you created earlier, choose javascript, choose `no` for ESLint, and `yes` to install all depedencies.
    ```bash
    firebase init
    ```
3. Move to the functions directory and download the Firebase functions using the `firebase.sh` script. This script will download the files containing the functions necessary to display the status.
    ```bash
    cd functions/
    curl https://raw.githubusercontent.com/bossley9/mc-server/master/firebase.sh | bash
    ```
    Then proceed to upload these functions to the cloud. You may need to specify in the command line which Firebase project you would like to use. Select the project you just created.
    ```bash
    firebase deploy --only functions
    ```
4. Go to the [Firebase console](https://console.firebase.google.com/) and select your project. In the side panel on the left, select `Functions`. The url displayed will be the base url for your server. Open this url in a browser. Your endpoint will be under the `/status` path. When the server is active, the server will display the ip and status information at this url.
    For example, your url endpoint will look something like:
    ```
    https://us-central1-my-Project.cloudfunctions.net/app/status
    ```
    When opened in a browser, this url show display `{}`. Verify this is displaying.

    Save this url endpoint.

