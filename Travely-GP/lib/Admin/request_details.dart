import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travely/Screens/loading.dart';

class ProviderRequestDetails extends StatefulWidget {
  final docId,
      username,
      imageUrl,
      address,
      phone,
      serviceProvider,
      email,
      password;

  ProviderRequestDetails({
    @required this.docId,
    @required this.username,
    @required this.imageUrl,
    @required this.address,
    @required this.phone,
    @required this.serviceProvider,
    @required this.email,
    @required this.password,
  });

  @override
  _ProviderRequestDetailsState createState() => _ProviderRequestDetailsState();
}

class _ProviderRequestDetailsState extends State<ProviderRequestDetails> {
  bool _isLoading = false;
  String _userID;
  String _token;
  double btnSize = 60;

  confirmRequest() async {
    final String url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyChe1hbKXn2Yzo0j86-veVZ0UNQsF8PXr0";
    try {
      setState(() {
        _isLoading = true;
      });

      final res = await http.post(Uri.parse(url),
          body: json.encode({
            'email': widget.email,
            'password': widget.password,
            'returnSecureToken': true,
          }));
      final resData = json.decode(res.body);
      print(resData);
      _token = resData['idToken'];
      _userID = resData['localId'];
      if (resData['error'] != null) {
        throw "${resData['error']['message']}";
      }
      await FirebaseFirestore.instance
          .collection("service providers")
          .doc(_userID)
          .set({
        "ID": _userID,
        "username": widget.username,
        "email": widget.email,
        "password": widget.password,
        "address": widget.address,
        "phone": widget.phone,
        "role": "Service Provider",
        "serviceProvider": widget.serviceProvider,
        "imageUrl": widget.imageUrl,
      });
    } catch (e) {
      throw e;
    }
  }

  deleteRequest() {
    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance
        .collection("service providers requests")
        .doc(widget.docId)
        .delete();
  }

  deleteImage() async {
    if (widget.imageUrl != null) {
      var firebaseStorageRef =
          FirebaseStorage.instance.refFromURL(widget.imageUrl);

      await firebaseStorageRef.delete();
    }
  }

  imageDialog() {
    return InteractiveViewer(
      child: Dialog(
        child: Container(
          width: double.infinity,
          color: Colors.black38,
          child: Stack(
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  cutName() {
    String username = widget.username;
    double size = 0.0;
    if (username.length <= 17) {
      size = 35;
    } else if (username.length <= 20) {
      size = 30;
    } else if (username.length <= 23) {
      size = 22;
    } else if (username.length <= 27) {
      size = 20;
    } else if (username.length <= 30) {
      size = 18;
    }

    String firstName = "";

    for (int i = 0; i < username.length; i++) {
      if (username[i] != " ") {
        firstName += username[i];
      } else if (firstName == "Abd" ||
          firstName == "abd" ||
          firstName == "abD" ||
          firstName == "aBd" ||
          firstName == "aBD" ||
          firstName == "AbD" ||
          firstName == "ABd" ||
          firstName == "ABD") {
        firstName += username[i];
      } else if (username[i] == " ") break;
    }

    String secondHalf = username.substring(firstName.length);

    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 1.5),
                bottom: BorderSide(color: Colors.black, width: 1.5),
                left: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: ClipPath(
              clipper: NameCutter(),
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  right: 20,
                  left: 10,
                ),
                child: Text(
                  firstName.trim(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: size,
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black, width: 1.5),
                bottom: BorderSide(color: Colors.black, width: 1.5),
                right: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              right: 10,
              left: 0.0,
            ),
            child: Text(
              secondHalf.trim(),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: size,
              ),
            ),
          ),
        ],
      ),
    );
  }

  displayData() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.miscellaneous_services_sharp),
              SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  widget.serviceProvider,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.mail_sharp),
              SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.phone),
              SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  widget.phone,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.home),
              SizedBox(
                width: 7,
              ),
              Expanded(
                child: Text(
                  widget.address,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Container(
                              height: 320,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(35),
                                  bottomLeft: Radius.circular(35),
                                ),
                                child: Container(
                                  color: Colors.black38,
                                  child: InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (_) => imageDialog());
                                    },
                                    child: Image.network(
                                      widget.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            cutName(),
                            displayData(),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 4.0,
                        left: 5.0,
                        right: 0.0,
                        child: Opacity(
                          opacity: 0.8,
                          child: AppBar(
                            leading: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFBC0505),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(50)),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),
                            backgroundColor: Colors.blue.withOpacity(0.0),
                            elevation: 0.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        child: Stack(
                          children: [
                            Container(
                              height: btnSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black54,
                                    Colors.black,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              padding: EdgeInsets.only(
                                top: 16,
                                bottom: 16,
                                left: 10,
                                right: 15,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                ),
                                ClipPath(
                                  clipper: DolDurmaClipper(holeRadius: 17),
                                  child: Container(
                                    height: btnSize,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.lightGreenAccent,
                                          Colors.green
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Confirm',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 15,
                                      bottom: 15,
                                      left: 20,
                                      right: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          confirmRequest().then((_) {
                            deleteRequest();
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                      InkWell(
                        child: Stack(
                          children: [
                            Container(
                              height: btnSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black54,
                                    Colors.black,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                                size: 30,
                              ),
                              padding: EdgeInsets.only(
                                top: 13,
                                bottom: 13,
                                left: 10,
                                right: 18,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 45,
                                ),
                                ClipPath(
                                  clipper: DolDurmaClipper(holeRadius: 17),
                                  child: Container(
                                    height: btnSize,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF6F6F),
                                          Color(0xFFC91D1D),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    padding: EdgeInsets.only(
                                      top: 15,
                                      bottom: 15,
                                      left: 20,
                                      right: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          deleteRequest();
                          deleteImage().then((_) {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class DolDurmaClipper extends CustomClipper<Path> {
  DolDurmaClipper({@required this.holeRadius});

  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..lineTo(0.0, size.height / 2 + holeRadius / 2)
      ..arcToPoint(
        Offset(0.0, size.height / 2 - holeRadius / 2),
        clockwise: false,
        radius: Radius.circular(1),
      );

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DolDurmaClipper oldClipper) => true;
}

class NameCutter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width - 20.0, size.height)
      ..lineTo(0.0, size.height)
      ..lineTo(20.0, 0.0);

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(NameCutter oldClipper) => true;
}
