import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travely/Admin/request_details.dart';
import 'package:travely/Screens/loading_wave.dart';

Color thc = Color(0xFF007965);

class RequestItem extends StatefulWidget {
  final docId,
      username,
      imageUrl,
      address,
      phone,
      serviceProvider,
      email,
      password;

  RequestItem({
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
  RequestItemState createState() => RequestItemState();
}

class RequestItemState extends State<RequestItem> {
  String _userID;
  String _token;

  bool _isConfirming = false;

  confirmRequest() async {
    final String url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyChe1hbKXn2Yzo0j86-veVZ0UNQsF8PXr0";
    try {
      setState(() {
        _isConfirming = true;
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
        "rate": 0.0,
        "numOfReviews": 0.0,
        "sumOfRates": 0.0,
      });
    } catch (e) {
      throw e;
    }
  }

  deleteRequest() {
    setState(() {
      _isConfirming = true;
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

  selectRequest() {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) {
              return ProviderRequestDetails(
                docId: widget.docId,
                username: widget.username,
                email: widget.email,
                password: widget.password,
                address: widget.address,
                phone: widget.phone,
                serviceProvider: widget.serviceProvider,
                imageUrl: widget.imageUrl,
              );
            }
        )
    );
  }

  showConfirmationDialog(String action) {
    showDialog(
      context: this.context,
      builder: (ctx) =>
          AlertDialog(
            title: Text("$action Provider Request!"),
            content: Text(
                "Are you sure you want to ${action.toLowerCase()} ${widget
                    .username} request ?"),
            actions: [
              FlatButton(
                onPressed: () {
                  if (action == "Delete") {
                    deleteRequest();
                    deleteImage().then((_) {
                      setState(() {
                        _isConfirming = false;
                      });
                    });
                  } else {
                    confirmRequest().then((_) {
                      deleteRequest();
                      setState(() {
                        _isConfirming = false;
                      });
                    });
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text("$action", style: TextStyle(
                  color: action == "Confirm" ? Colors.green : Colors.red,),),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("Close", style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isConfirming
        ? Center(
      child: LoadingWave(),
    )
        : InkWell(
      onTap: () {
        selectRequest();
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Image.network(
                    widget.imageUrl,
                    height: 215,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Container(
                    width: 300,
                    color: Colors.black54,
                    padding:
                    EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Text(
                      widget.username,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                      ),
                      softWrap: true,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(.0),
              child: Column(
                children: [
                  Container(
                    color: thc,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.format_quote,
                            size: 18,
                            color: Colors.white,
                          ),
                          Text(
                            "${widget.serviceProvider}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.format_quote,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Icon(Icons.deck),
                              Text(
                                " Details",
                                style: TextStyle(),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          selectRequest();
                        },
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              Text(
                                " Confirm",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          showConfirmationDialog("Confirm");
                        },
                      ),
                      InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              Text(
                                " Delete",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          showConfirmationDialog("Delete");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
