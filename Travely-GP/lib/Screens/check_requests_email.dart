import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/email_existance_checker_provider.dart';

class EmailRequestsChecker {
  final String email, password;
  final bool isLoginScreen;

  EmailRequestsChecker(this.email, this.password, this.isLoginScreen);

  var snapshotDocs;
  bool checker = false;

  getDocs() async {
    snapshotDocs = await FirebaseFirestore.instance
        .collection("service providers requests")
        .get();
  }

  checkCollection() async {
    await getDocs().then((_) {
      if (snapshotDocs.docs.length == 0) {
        checker = false;
      } else {
        checker = true;
      }
    });
  }

  checkEmailRequest(BuildContext context) async {
    bool condition;
    bool isAuthCondition;
    var docId;

    await checkCollection();

    if (isLoginScreen == false) {
      try {
        FirebaseAuth _auth = FirebaseAuth.instance;
        await _auth
            .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
            .then((_) async {
          isAuthCondition = true;
          await _auth
              .signInWithEmailAndPassword(email: email, password: password)
              .then(
            (_) {
              print("email and password: $email.....$password");
              var user = _auth.currentUser;
              print("New user: $user");
              user.delete();
              print("isAuthCondition: $isAuthCondition");
            },
          );
        }).catchError((onError) {
          print("onError: $onError");
          print("Before if");
          isAuthCondition = false;
          print("isAuthCondition: $isAuthCondition");
        });
      } catch (signUpError) {
        print("onError: $signUpError");
      }
    }

    print("Checker: $checker");
    if (checker == true) {
      await FirebaseFirestore.instance
          .collection('service providers requests')
          .get()
          .then((QuerySnapshot snapshot) async {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (int i = 0; i < docs.length; i++) {
          var docEmail = docs[i]['email'];
          var docPassword = docs[i]['password'];
          if (isLoginScreen == true) {
            condition = email.toString() == docEmail && password == docPassword;
            if (condition == true) {
              docId = docs[i]['ID'];
              break;
            }
          } else {
            condition = email.toString() != docEmail && isAuthCondition == true;
            if (condition == false) {
              docId = docs[i]['ID'];
              break;
            }
          }
        }
      });
    } else {
      if (isLoginScreen == false) {
        if (isAuthCondition == true) {
          condition = true;
        } else {
          condition = false;
        }
      } else
        condition = false;
    }

    print("Condition: $condition");
    print("ID: $docId");
    Provider.of<EmailExistence>(context, listen: false)
        .setExistence(result: condition, id: docId);
    print(
        "ID from provider: ${Provider.of<EmailExistence>(context, listen: false).id}");
  }
}
