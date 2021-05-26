import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/auth_provider.dart';
import 'package:travely/Providers/email_existance_checker_provider.dart';
import 'package:travely/Providers/registration_parameters.dart';
import 'package:travely/Registration%20form/waiting_list.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Screens/check_requests_email.dart';
import 'package:travely/auth/auth_screen.dart';

class Confirmation extends StatefulWidget {
  final String eMail,
      password,
      urlSegment,
      username,
      address,
      phone,
      role,
      gender;
  final PickedFile imageFile;
  final DateTime dateOfBirth;
  final String serviceProvider;
  final int code;

  Confirmation(
    this.code,
    this.eMail,
    this.password,
    this.urlSegment,
    this.username,
    this.address,
    this.phone,
    this.role,
    this.imageFile, {
    this.dateOfBirth,
    this.gender,
    this.serviceProvider,
  });

  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation>
    with SingleTickerProviderStateMixin {
  String imageFileUrl = "";
  var codeController = TextEditingController();
  bool checkCode = true, _isLoading = false;

  var animController;

  @override
  void initState() {
    animController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    super.initState();
  }

  checkCodeFn() {
    bool _isNumber;
    try {
      int checker = int.parse(codeController.text);
      _isNumber = true;
    } catch (e) {
      _isNumber = false;
    }

    if (_isNumber &&
        codeController.text != "" &&
        widget.code == int.parse(codeController.text)) {
      setState(() {
        checkCode = true;
      });
    } else {
      setState(() {
        checkCode = false;
        animController.forward(from: 0.0);
      });
    }
    return checkCode;
  }

  showErrorDialog(String message) {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("An Error Occurred!"),
        content: Text(message),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  bool tryOrCatch = true;

  submit() async {
    try {
      File imageFileFinal = (File(widget.imageFile.path));
      String fileName = basename(imageFileFinal.path);
      print("gggggggggggggggggggg ${widget.imageFile.path}");
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('Images/').child(fileName);
      print("BOm bOM bom BOM");
      await firebaseStorageRef.putFile(imageFileFinal);
      imageFileUrl = await firebaseStorageRef.getDownloadURL();

      var providerHeader = Provider.of<RegParam>(this.context, listen: false);

      print("Phone Number is: ${widget.phone}");
      print(
          "Traveler Or Provider value is: ${providerHeader.travelerOrProvider}");
      print("Gender is: ${providerHeader.gender}");
      print("Service Provider type is: ${providerHeader.serviceProvider}");
      print("Birth date is: ${providerHeader.dateOfBirth}");

      if (widget.role == "Traveler") {
        await Provider.of<Auth>(this.context, listen: false).authentication(
            widget.eMail,
            widget.password,
            "signUp",
            widget.username,
            widget.address,
            widget.phone,
            widget.role,
            imageFileUrl,
            dateOfBirth: providerHeader.dateOfBirth,
            gender: providerHeader.gender);
      } else if (widget.role == "Service Provider") {
        await Provider.of<Auth>(this.context, listen: false).authentication(
          widget.eMail,
          widget.password,
          "signUp",
          widget.username,
          widget.address,
          widget.phone,
          widget.role,
          imageFileUrl,
          serviceProvider: providerHeader.serviceProvider,
        );
      } else {
        print("This did not take any value");
      }
    } catch (error) {
      setState(() {
        tryOrCatch = false;
      });
      var errorMessage = "Authentication failed!";
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = "This E-mail address is already used";
      } else if (error.toString().contains('INVALID_EMAIL') ||
          error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = "E-mail or password is invalid";
      } else if (error.toString().contains("WEAK_PASSWORD")) {
        errorMessage =
            'This password is too weak, you must use letters and numbers';
      } else if (error.toString().contains("EMAIL_NOT_FOUND")) {
        errorMessage = "Could not find this user E-mail";
      }
      showErrorDialog(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(animController)
          ..addStatusListener(
            (status) {
              if (status == AnimationStatus.completed) {
                animController.reverse();
              }
            },
          );

    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(23.0, 23.0),
              child: Container(
                color: Theme.of(context).primaryColor,
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                color: Theme.of(context).primaryColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 25, left: 10, right: 10, bottom: 15),
                  child: Column(
                    children: [
                      Text(
                        "Check Your E-mail",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 37,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Please write the confirmation code in the email we sent to",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        "${widget.eMail}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.red,
                        label: Text(
                          'Change email',
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      TextField(
                        controller: codeController,
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            labelText: "Confirmation Code",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.confirmation_number_sharp,
                              color: Colors.white,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(60),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 2,
                                ))),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      AnimatedBuilder(
                        animation: offsetAnimation,
                        builder: (buildContext, child) {
                          return Visibility(
                            visible: !checkCode,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: offsetAnimation.value + 24.0,
                                  right: 24.0 - offsetAnimation.value),
                              color: Colors.red,
                              child: Text(
                                "The confirmation code is wrong",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 45,
                      ),
                      FlatButton(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: Theme.of(context).accentColor,
                        splashColor: Colors.red,
                        onPressed: () {
                          if (checkCodeFn()) {
                            setState(() {
                              _isLoading = true;
                            });
                            EmailRequestsChecker(
                              widget.eMail,
                              widget.password,
                              false,
                            ).checkEmailRequest(context).then((_) {
                              bool isNotExist = Provider.of<EmailExistence>(
                                  context,
                                  listen: false)
                                  .emailExist;
                              print("isExist: $isNotExist");
                              if (isNotExist) {
                                submit().then(
                                      (_) {
                                    if (tryOrCatch) {
                                      if (widget.role == "Service Provider") {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                WaitingList(),
                                          ),
                                              (route) => false,
                                        );
                                      } else {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                AuthScreen(),
                                          ),
                                              (route) => false,
                                        );
                                      }
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  },
                                );
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                                showErrorDialog("This email is in use");
                              }
                            });
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
