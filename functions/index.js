const functions = require('firebase-functions');
const express = require('express');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);
const db = admin.database();
const statusesRef = db.ref('statuses');

const app = express();

// GET status
app.get('/status', (req, res) => {
  
  statusesRef.orderByKey().limitToLast(1).once('value', (snapshot) => {

    let response;
    
    snapshot.forEach((doc) => {
      const { ip, message, status } = doc.val();
      
      if (!response) {
        response = {
          ip,
          message: message || '',
          status,
        }
      }
    });
    
    res.send(response || {});

  }, (e) => res.send({ error: e }));
  
});

// POST new status
app.post('/status', async (req, res) => {
  const { ip, message, status } = req.body;
  
  if (ip && status) {
    let errors = [];
    
    // retrieve and remove statuses older than six months
    
    let threshold = new Date();
    threshold.setMonth(threshold.getMonth() - 6);

    let removed = 0;
    
    try {
      let snapshot = await statusesRef
        .orderByChild('lastUpdated')
        .endAt(threshold.toISOString())
        .once('value');

      snapshot.forEach((doc) => {
        removed++;
        doc.getRef().remove();
      });
    
    } catch (e) {
      errors.push({ error: e, message: 'unable to retrieve outdated statuses' });
    }

    // add new status
    
    try {
      await statusesRef.push().set({
        ip,
        message: message || '',
        status,
        lastUpdated: new Date().toISOString(),
      });
    } catch (e) {
      errors.push({ error: e, message: 'unable to add a new status' });
    }
        
    res.send({
      message: `added 1 status and removed ${removed} statuses`,
      errors,
    });

  } 
  else res.send({ error: 'ip or status is null.' });

});

exports.app = functions.https.onRequest(app);
