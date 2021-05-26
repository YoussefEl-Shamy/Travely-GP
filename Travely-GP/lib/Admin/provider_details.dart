import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/admin_email_pass_provider.dart';
import 'package:travely/Screens/loading_wave.dart';

class ProviderDetails extends StatefulWidget {
  final providerId;

  const ProviderDetails({this.providerId});

  @override
  _ProviderDetailsState createState() => _ProviderDetailsState();
}

class _ProviderDetailsState extends State<ProviderDetails> {
  var provider, providerName, imageUrl, email, password;
  bool _isLoading = false;

  getProviderName() {
    provider = FirebaseFirestore.instance
        .collection("service providers")
        .doc(widget.providerId)
        .snapshots();
    return StreamBuilder(
      stream: provider,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWave();
        }
        providerName = snapshot.data['username'];
        return Text(providerName);
      },
    );
  }

  imageDialog() {
    return InteractiveViewer(
      child: Dialog(
        child: Container(
          width: double.infinity,
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () {
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

  getProviderDetails() {
    return StreamBuilder(
      stream: provider,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWave();
        }
        email = snapshot.data['email'];
        password = snapshot.data['password'];
        var address = snapshot.data['address'];
        var phone = snapshot.data['phone'];
        var serviceProvider = snapshot.data['serviceProvider'];
        imageUrl = snapshot.data['imageUrl'];
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(35),
                bottomLeft: Radius.circular(35),
              ),
              child: InkWell(
                onTap: () {
                  showDialog(context: context, builder: (_) => imageDialog());
                },
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.black38,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            "$email",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            phone,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.miscellaneous_services_sharp),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            serviceProvider,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.home),
                        SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getProviderName();
    getProviderDetails();
  }

  deleteProvider() async {
    await AuthService().deleteUser(context, email, password);

    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance
        .collection("service providers")
        .doc(widget.providerId)
        .delete();

    deleteImage(imageUrl).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  deleteImage(String imageUrl) async {
    if (imageUrl != null) {
      var firebaseStorageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      await firebaseStorageRef.delete();
    }
  }

  showDeleteDialog(BuildContext buildContext) {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Provider!"),
        content:
            Text("Are you sure you want to delete that service provider ?"),
        actions: [
          FlatButton(
            onPressed: () {
              deleteProvider().then((_) {
                setState(() {
                  _isLoading = false;
                });
              });
              Navigator.of(ctx).pop();
              Navigator.of(buildContext).pop();
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getProviderName(),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            color: Colors.white,
            onPressed: () {
              showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: getProviderDetails(),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future deleteUser(BuildContext context, String email, String password) async {
    try {
      var user = _auth.currentUser;
      print("Old user: $user");
      _auth.signOut().then((_) {
        _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((_) {
          print("email and password: $email.....$password");
          user = _auth.currentUser;
          print("New user: $user");
          user.delete();
          var admin = Provider.of<IdEmailPassProvider>(context, listen: false);
          _auth
              .signInWithEmailAndPassword(
                  email: admin.email, password: admin.password)
              .then((_) {
            user = _auth.currentUser;
            print("Current user: $user");
            return true;
          });
        });
      });
    } catch (e) {
      print(e.toString());
      print(e);
      print("LOL Catch");
      return null;
    }
  }
}
