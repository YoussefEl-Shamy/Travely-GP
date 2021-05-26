/* eslint no-var: off */
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp(functions.config().firebase);

var msgData;

exports.offerTrigger = functions.firestore.document(
    "service providers requests/{requestId}"
).onCreate((snapsot, context) => {
  msgData = snapsot.data();

  admin.firestore().collection("admin").get().then((snapshots) => {
    var tokens = [];
    if (snapshots.empty) {
      console.log("No Devices");
    } else {
      for (var token of snapshots.docs) {
        tokens.push(token.data().devToken);
      }

      var payload = {
        "notification": {
          "title": "New Request arrived !",
          "body": "From " + msgData.username,
          "sound": "default",
        },
        "data": {
          "sendername": msgData.username,
          "message": msgData.username,
        },
      };

      return admin.messaging().sendToDevice(tokens, payload).then((response) =>{
        console.log("Pushed them all !");
      }).catch((err) => {
        console.log(err);
      });
    }
  });
});
