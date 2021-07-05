import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travely/Admin/admin_home_page.dart';
import 'package:travely/Providers/email_existance_checker_provider.dart';
import 'package:travely/Registration%20components/backgroung_picture.dart';
import 'package:travely/Registration%20components/header.dart';
import 'package:travely/Registration%20form/waiting_list.dart';
import 'package:travely/Traveler/traveler_home_page.dart';
import 'package:travely/Screens/check_requests_email.dart';
import 'package:travely/Service%20provider/service_provider_home_page.dart';
import 'package:travely/auth/auth_form.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  final isFromPackageDetails;

  const AuthScreen({this.isFromPackageDetails = false});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String message = "Error Occurred";

  void _submitAuthForm(String email, String password, String username,
      bool isLogin, BuildContext ctx) async {
    UserCredential authResult;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin == true) {
        authResult = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        var userId = FirebaseAuth.instance.currentUser.uid;
        print("2-Try to get the user id here: $userId");
        setRole(userId).then((_) {
          print("User role: $_role");
          if (_role == "admin") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AdminHomePage(),
              ),
                  (route) => false,
            );
          } else if (_role == "service provider") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SPHomePage(),
              ),
                  (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => FirstPage(),
              ),
                  (route) => false,
            );
          }
        });
      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
      }
    } on FirebaseAuthException catch (e) {
      EmailRequestsChecker(email, password, true).checkEmailRequest(context).then((_){
        bool isNotExist = Provider.of<EmailExistence>(context, listen: false).emailExist;
        print("isExist: $isNotExist");
        if(isNotExist){
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_){
            return WaitingList();
          }));
        } else{
          if (e.code == 'weak-password') {
            message = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            message = 'The account already exists for that email.';
          } else if (e.code == 'user-not-found') {
            message = 'No user found for that email.';
          } else if (e.code == 'wrong-password') {
            message = 'Wrong E-mail or password provided for that user.';
          }
          Scaffold.of(ctx).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(ctx).errorColor,
          ));
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _role = "";

  checkExistInAdmin(String userId) async {
    try {
      await FirebaseFirestore.instance.doc("admin/$userId").get().then((doc) {
        if (doc.exists) {
          _role = "admin";
          print("TheAdmin is here");
        }
      });
    } catch (e) {
      print(e);
    }
  }

  checkExistInSP(String userId) async {
    try {
      await FirebaseFirestore.instance
          .doc("service providers/$userId")
          .get()
          .then((doc) {
        if (doc.exists) {
          _role = "service provider";
          print("TheProvider is here");
        }
      });
    } catch (e) {
      print(e);
    }
  }

  checkExistInTravelers(String userId) async {
    try {
      await FirebaseFirestore.instance
          .doc("travelers/$userId")
          .get()
          .then((doc) {
        if (doc.exists) _role = "traveler";
      });
    } catch (e) {
      print(e);
    }
  }

  setRole(String userId) async {
    await checkExistInAdmin(userId);
    await checkExistInSP(userId);
    await checkExistInTravelers(userId);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0.0, 0.0),
        child: Container(),
      ),
      body: Container(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  children: [
                    Header(signUp: false),
                    Stack(
                      children: [
                        BackgroundPicture(),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 20.0, right: 15.0),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: 0.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Container(
                                    color: Colors.white,
                                    height: MediaQuery.of(context).size.height /
                                        1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        AuthForm(_submitAuthForm, _isLoading, isFromPackageDetails: widget.isFromPackageDetails),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
