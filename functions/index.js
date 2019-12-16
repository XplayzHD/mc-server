const functions = require('firebase-functions');
const express = require('express');

const app = express();

app.get('/status', (req, res) => {
  res.send('express app get');
});

app.post('/status', (req, res) => {
  res.send('express app POST');
});

exports.app = functions.https.onRequest(app);
