const functions = require('firebase-functions');
const express = require('express');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
const db = admin.database();
const statusesRef = db.ref('statuses');

const app = express();

// GET status
app.get('/status', (req, res) => {
  //statusesRef.orderByChild()
  
  
  res.send('express app get');
});

// POST new status
app.post('/status', (req, res) => {
  const { ip, message, status } = req.body;
  
  // add new status
  
  if (ip && status) {

    statusesRef.push().set({
      ip,
      message: message || '',
      status,
      lastUpdated: new Date().toISOString(),
    });
  
    // delete old status(es)
    // TODO
    
    res.send({ message: 'Status post successful.' });
  } else {
    res.send({ error: 'ip or status is null.' });
  }

});

exports.app = functions.https.onRequest(app);
