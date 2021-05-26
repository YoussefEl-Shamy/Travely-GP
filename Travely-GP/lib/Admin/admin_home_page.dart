import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travely/Admin/request_item.dart';
import 'package:flutter/material.dart';
import 'package:travely/Providers/admin_email_pass_provider.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Screens/drawer_admin.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool checker = false, _isLoading = true;

  @override
  void initState() {
    super.initState();
    inputData();
    checkCollection();
    setState(() {
      _isLoading = false;
    });
  }

  final auth = FirebaseAuth.instance;

  void inputData() {
    final User user = auth.currentUser;
    final uid = user.uid;
    print("User ID: $uid");
    Provider.of<IdEmailPassProvider>(context, listen: false).setAdminId(uid);
    print(
        "User ID Provider: ${Provider.of<IdEmailPassProvider>(context, listen: false).id}");
  }

  var snapshotDocs;

  getDocs() async {
    snapshotDocs = await FirebaseFirestore.instance
        .collection("service providers requests")
        .get();
  }

  checkCollection() {
    getDocs().then((_) {
      if (snapshotDocs.docs.length == 0) {
        setState(() {
          checker = false;
        });
      } else {
        setState(() {
          checker = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Registration Requests"),
            ),
            body: checker
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('service providers requests')
                        .snapshots(),
                    builder: (ctx, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return Loading();
                      }

                      final docs = snapShot.data.docs;
                      return ListView.builder(
                        itemBuilder: (ctx, index) {
                          return RequestItem(
                            docId: docs[index]['ID'],
                            username: docs[index]['username'],
                            imageUrl: docs[index]['imageUrl'],
                            phone: docs[index]['phone'],
                            address: docs[index]['address'],
                            serviceProvider: docs[index]['serviceProvider'],
                            email: docs[index]['email'],
                            password: docs[index]['password'],
                          );
                        },
                        itemCount: docs.length,
                      );
                    },
                  )
                : Center(
                    child: Text("No requests found"),
                  ),
            drawer: MainDrawerAdmin(),
          );
  }
}
