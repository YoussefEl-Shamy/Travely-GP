import 'dart:io';
import 'dart:math';

import 'package:mailer2/mailer.dart';
import 'package:toast/toast.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/registration_parameters.dart';
import 'package:travely/Providers/traveler_providerServices_details_provider.dart';
import 'package:travely/Registration%20components/backgroung_picture.dart';
import 'package:travely/Registration%20components/header.dart';
import 'package:travely/Registration%20components/make_your_choice.dart';
import 'package:travely/Registration components/error_text.dart';
import 'package:travely/Registration%20components/password_field.dart';
import 'package:travely/Registration%20components/phone_field.dart';
import 'package:travely/Registration%20components/provider_additional_details.dart';
import 'package:travely/Registration%20components/text_field.dart';
import 'package:travely/Registration%20components/traveler_additional_details.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Screens/registration_confirmation_screen.dart';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

Color thc = Color(0xFF007965);

class _RegistrationFormState extends State<RegistrationForm>
    with SingleTickerProviderStateMixin {
  var usernameController = TextEditingController();
  var eMailController = TextEditingController();
  var passwordController = TextEditingController();
  var addressController = TextEditingController();
  var phoneController = TextEditingController();

  String role, phoneNumber;
  bool _isLoading = false;

  PermissionStatus imageState;
  PickedFile imageFile;
  String imageFileUrl = "";
  final ImagePicker _picker = ImagePicker();

  Future getImage(BuildContext ctx, ImageSource source) async {
    source == ImageSource.camera
        ? imageState = await Permission.camera.status
        : imageState = await Permission.storage.status;
    if (imageState.isGranted) {
      var tempImage = await _picker.getImage(
        source: source,
        maxWidth: 450,
        maxHeight: 450,
      );
      setState(() {
        imageFile = tempImage;
      });
    } else {
      AlertDialog dialog = AlertDialog(
        content: Text(
          source == ImageSource.camera
              ? 'This App needs to camera access to get profile picture'
              : 'This App needs to gallery access to get profile picture',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.pop(ctx);
                AppSettings.openAppSettings();
              });
            },
            child: Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          FlatButton(
            onPressed: () {
              setState(() {
                Navigator.pop(ctx);
              });
            },
            child: Text(
              "Deny",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
        ],
      );
      showDialog(
        context: ctx,
        builder: (_) => dialog,
      );
    }
  }

  double getRadiansFromDegree(double degree) {
    double unitRadian = 57.295779513;
    return degree / unitRadian;
  }

  AnimationController animationController;
  Animation degOneTranslationAnimation, degTwoTranslationAnimation;
  Animation rotationAnimation;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    degOneTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.3), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.3, end: 1.0), weight: 25.0)
    ]).animate(animationController);
    degTwoTranslationAnimation = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.5), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.5, end: 1.0), weight: 45.0)
    ]).animate(animationController);
    rotationAnimation = Tween<double>(begin: 180.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  generateCode() {
    int min = 10265;
    int max = 99721;
    Random rnd = new Random();
    code = min + rnd.nextInt(max - min);
    print("$code is in the range of $min and $max");
  }

  goToConfirmationScreen(BuildContext ctx) {
    var providerHeader = Provider.of<RegParam>(this.context, listen: false);
    if (providerHeader.travelerOrProvider == 1) {
      setState(() {
        role = "Traveler";
      });
    } else if (providerHeader.travelerOrProvider == 2) {
      setState(() {
        role = "Service Provider";
        birthDateChecker = false;
      });
    }
    phoneNumber = providerHeader.dialCode + phoneController.text.trim();
    print("Phone number is trimmed: $phoneNumber");

    print("Check Role cause it should be: $role");
    if (validateInfo(role)) {
      Navigator.of(ctx).push(
        MaterialPageRoute(
          builder: (_) {
            return Confirmation(
                code,
                eMailController.text.trim(),
                passwordController.text.trim(),
                "signUp",
                usernameController.text.trim(),
                addressController.text.trim(),
                phoneNumber,
                role,
                imageFile);
          },
        ),
      );
    }
  }

  int code = 0;
  bool _isSent = false;

  sendEmail() async {
    print("Sending the email");
    var providerHeader = Provider.of<RegParam>(this.context, listen: false);
    if (providerHeader.travelerOrProvider == 1) {
      setState(() {
        role = "Traveler";
      });
    } else if (providerHeader.travelerOrProvider == 2) {
      setState(() {
        role = "Service Provider";
        birthDateChecker = false;
      });
    }

    print("Sending the email after check the role");
    if (validateInfo(role)) {
      setState(() {
        _isLoading = true;
      });
      var options = new GmailSmtpOptions()
      ..username = 'travely.droid@gmail.com'
      ..password = '010a010B010c';
      var emailTransport = new SmtpTransport(options);

      var envelope = new Envelope()
      ..from = 'travely.droid@gmail.com'
      ..recipients.add(eMailController.text.trim().toLowerCase())
      ..subject = 'Confirmation Message ${DateTime.now()}'
      ..text = 'Thanks for joining us.\n confirmation code:'
      ..html = "Thanks for joining us. confirmation code: <b>$code</b>";

      await emailTransport.send(envelope).then((envelope) {
      print('Email sent!');
      _isSent = true;
      print("The email should be sent");
    }).catchError((e) {
      print('Error occurred: $e');
      _isSent = false;
      setState(() {
        _isLoading = false;
      });
      Toast.show("Sorry something went wrong, try again.", context,
          duration: 4, gravity: Toast.CENTER);
    });
    }
  }

  /*sendEmail() async {
    print("1");
    var options = new GmailSmtpOptions()
      ..username = 'travely.droid@gmail.com'
      ..password = '010a010B010c';
    print("2");
    var emailTransport = new SmtpTransport(options);
    print("3");
    // Create our mail/envelope.
    var envelope = new Envelope()
      ..from = 'travely.droid@gmail.com'
      ..recipients.add(eMailController.text.trim().toLowerCase())
      ..subject = 'Confirmation Message ${DateTime.now()}'
      ..text = 'Thanks for joining us.\n confirmation code:'
      ..html = "Thanks for joining us. confirmation code: <b>$code</b>";
    print("4");
    // Email it.
    await emailTransport.send(envelope).then((envelope) {
      print('Email sent!');
      _isSent = true;
      print("The email should be sent");
    }).catchError((e) {
      print('Error occurred: $e');
      _isSent = false;
      setState(() {
        _isLoading = false;
      });
      Toast.show("Sorry something went wrong, try again.", context,
          duration: 4, gravity: Toast.CENTER);
    });
  }*/

  bool usernameChecker = false,
      emailChecker = false,
      passwordChecker = false,
      addressChecker = false,
      phoneChecker = false,
      roleChecker = false,
      birthDateChecker = false;

  checkUsername() {
    if (usernameController.text == "" ||
        usernameController.text.length < 3 ||
        usernameController.text.length > 30) {
      setState(() {
        usernameChecker = true;
      });
    } else {
      setState(() {
        usernameChecker = false;
      });
    }
    return !usernameChecker;
  }

  checkEmail() {
    if (eMailController.text == "" || !eMailController.text.contains("@")) {
      setState(() {
        emailChecker = true;
      });
    } else {
      setState(() {
        emailChecker = false;
      });
    }
    return !emailChecker;
  }

  checkPassword() {
    if (passwordController.text == "" || passwordController.text.length < 7) {
      setState(() {
        passwordChecker = true;
      });
    } else {
      setState(() {
        passwordChecker = false;
      });
    }
    return !passwordChecker;
  }

  checkAddress() {
    if (addressController.text == "") {
      setState(() {
        addressChecker = true;
      });
    } else {
      setState(() {
        addressChecker = false;
      });
    }
    return !addressChecker;
  }

  checkPhoneNumber() {
    if (phoneController.text == "") {
      setState(() {
        phoneChecker = true;
      });
    } else {
      setState(() {
        phoneChecker = false;
      });
    }
    return !phoneChecker;
  }

  checkRole(String role) {
    if (role == null) {
      setState(() {
        roleChecker = true;
      });
    } else {
      setState(() {
        roleChecker = false;
      });
    }

    if (role == "Traveler" && checkDateOfBirth(role)) {
      return true;
    } else if (role == "Service Provider") {
      return true;
    } else {
      return false;
    }
  }

  checkDateOfBirth(String role) {
    if (role == "Traveler" &&
        Provider.of<RegParam>(context, listen: false).dateOfBirth == null) {
      setState(() {
        birthDateChecker = true;
      });
    } else {
      setState(() {
        birthDateChecker = false;
      });
    }
    return !birthDateChecker;
  }

  validateInfo(String role) {
    checkUsername();
    checkAddress();
    checkEmail();
    checkPassword();
    checkPhoneNumber();
    checkRole(role);

    if (imageFile != null &&
        checkUsername() &&
        checkAddress() &&
        checkEmail() &&
        checkPassword() &&
        checkPhoneNumber() &&
        checkRole(role)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("The beginning");
    Size size = MediaQuery.of(context).size;
    return _isLoading
        ? Loading()
        : Scaffold(
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Header(signUp: true),
                          Stack(
                            children: [
                              BackgroundPicture(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, top: 25.0, right: 12.0),
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              1.5,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          Center(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                bottom: BorderSide(
                                                    color: thc, width: 2.5),
                                              )),
                                              child: Text(
                                                "SignUp",
                                                style: TextStyle(
                                                  color: thc,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          InkWell(
                                            child: CircleAvatar(
                                              radius: 40,
                                              backgroundColor: Colors.grey,
                                              backgroundImage: imageFile != null
                                                  ? FileImage(
                                                      File(imageFile.path))
                                                  : null,
                                            ),
                                            onTap: () {
                                              animationController.isCompleted
                                                  ? animationController
                                                      .reverse()
                                                  : animationController
                                                      .forward();
                                            },
                                          ),
                                          imageFile == null
                                              ? FlatButton(
                                                  child: Text(
                                                    "No Image Selected",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                      decoration: TextDecoration
                                                          .underline,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    animationController
                                                            .isCompleted
                                                        ? animationController
                                                            .reverse()
                                                        : animationController
                                                            .forward();
                                                  },
                                                )
                                              : Text(""),
                                          SizedBox(height: 15),
                                          MyTextField(
                                            usernameController,
                                            "Username",
                                            "Enter your full name",
                                            Icon(Icons.person),
                                            TextInputType.text,
                                          ),
                                          ErrorText(
                                            errorText:
                                                "Username should be in range 3 and 30 characters",
                                            isVisible: usernameChecker,
                                          ),
                                          SizedBox(height: 15),
                                          TextField(
                                            controller: eMailController,
                                            decoration: InputDecoration(
                                                labelText: "E-mail",
                                                hintText: "Enter your email.",
                                                prefixIcon: Icon(Icons.email),
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.redAccent))),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            autofillHints: [
                                              AutofillHints.email
                                            ],
                                          ),
                                          ErrorText(
                                            errorText: "Enter valid email",
                                            isVisible: emailChecker,
                                          ),
                                          SizedBox(height: 15),
                                          PasswordField(passwordController),
                                          ErrorText(
                                            errorText:
                                                "Password is too weak, it should not be less than 7 characters",
                                            isVisible: passwordChecker,
                                          ),
                                          SizedBox(height: 15),
                                          MyTextField(
                                            addressController,
                                            "Address",
                                            "Enter your address",
                                            Icon(Icons.home),
                                            TextInputType.text,
                                          ),
                                          ErrorText(
                                            errorText:
                                                "Enter your address please",
                                            isVisible: addressChecker,
                                          ),
                                          SizedBox(height: 15),
                                          PhoneField(phoneController),
                                          ErrorText(
                                            errorText:
                                                "Enter your phone number please",
                                            isVisible: phoneChecker,
                                          ),
                                          SizedBox(height: 15),
                                          Choice(),
                                          ErrorText(
                                            errorText: "Select your role",
                                            isVisible: roleChecker,
                                          ),
                                          SizedBox(height: 15),
                                          Visibility(
                                            visible: Provider.of<ShowDetails>(
                                                    context,
                                                    listen: true)
                                                .cTAD,
                                            child: TAD(),
                                          ),
                                          ErrorText(
                                            errorText:
                                                "Pick your date of birth",
                                            isVisible: birthDateChecker,
                                          ),
                                          SizedBox(height: 15),
                                          Visibility(
                                            visible: Provider.of<ShowDetails>(
                                                    context,
                                                    listen: true)
                                                .cPAD,
                                            child: PAD(),
                                          ),
                                          SizedBox(height: 20),
                                          FlatButton(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(15.0),
                                              child: Container(
                                                width: double.infinity,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  "Confirm",
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25)),
                                            color:
                                                Theme.of(context).accentColor,
                                            splashColor: Colors.red,
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              generateCode();
                                              sendEmail().then(
                                                (_) {
                                                  print("_isSent: $_isSent");
                                                  if (_isSent) {
                                                    print("_isSent: $_isSent");
                                                    goToConfirmationScreen(
                                                        context);
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Positioned(
                        right: 30,
                        bottom: 30,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            IgnorePointer(
                              child: Container(
                                color: Colors.black.withOpacity(0.0),
                                height: 150.0,
                                width: 150.0,
                              ),
                            ),
                            Transform.translate(
                              offset: Offset.fromDirection(
                                  getRadiansFromDegree(260),
                                  degOneTranslationAnimation.value * 85),
                              child: Transform(
                                transform: Matrix4.rotationZ(
                                    getRadiansFromDegree(
                                        rotationAnimation.value))
                                  ..scale(degOneTranslationAnimation.value),
                                alignment: Alignment.center,
                                child: CircularBtn(
                                  color: Colors.black,
                                  width: 55,
                                  height: 55,
                                  icon: Icon(
                                    Icons.image,
                                    color: Colors.white,
                                  ),
                                  onClick: () {
                                    print("gallery icon is clicked");
                                    getImage(context, ImageSource.gallery);
                                  },
                                ),
                              ),
                            ),
                            Transform.translate(
                              offset: Offset.fromDirection(
                                  getRadiansFromDegree(180),
                                  degTwoTranslationAnimation.value * 85),
                              child: Transform(
                                transform: Matrix4.rotationZ(
                                    getRadiansFromDegree(
                                        rotationAnimation.value))
                                  ..scale(degTwoTranslationAnimation.value),
                                alignment: Alignment.center,
                                child: CircularBtn(
                                  color: Color(0xFFf58634),
                                  width: 55,
                                  height: 55,
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onClick: () {
                                    print("camera icon is clicked");
                                    getImage(context, ImageSource.camera);
                                  },
                                ),
                              ),
                            ),
                            CircularBtn(
                              color: Theme.of(context).primaryColor,
                              width: 65,
                              height: 65,
                              icon: Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                              ),
                              onClick: () {
                                animationController.isCompleted
                                    ? animationController.reverse()
                                    : animationController.forward();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class CircularBtn extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Icon icon;
  final Function onClick;

  const CircularBtn({
    this.width,
    this.height,
    this.color,
    this.icon,
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      width: width,
      height: height,
      child: IconButton(
        icon: icon,
        enableFeedback: true,
        onPressed: onClick,
      ),
    );
  }
}
