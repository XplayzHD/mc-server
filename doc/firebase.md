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
2. In the directory of your choice, login and initialize Firebase.
  Make sure to choose Firebase functions and select the project you created in step 1. Choose Javascript as the language and say No to the ESLint installation.
  
  Install dependencies with npm.
    ```bash
    firebase login
    firebase init
    ```



<!--
3. Deploy the functions.
  ```bash
  firebase deploy --only functions
  ```
-->
