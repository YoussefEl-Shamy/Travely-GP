import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travely/Traveler/edit_profile_picture.dart';
import 'package:travely/Traveler/edit_traveler_profile.dart';

class TravelerProfile extends StatefulWidget {
  @override
  _TravelerProfileState createState() => _TravelerProfileState();
}

class _TravelerProfileState extends State<TravelerProfile> {
  String imageUrl = "";
  PermissionStatus imageState;
  PickedFile imageFile;
  String imageFileUrl = "";
  final ImagePicker _picker = ImagePicker();
  var username;
  var phone;
  var address;
  var email;
  var gender;
  var birth;
  var birthDate;

  imageDialog() {
    return InteractiveViewer(
      child: Dialog(
        child: Container(
          width: double.infinity,
          color: Colors.black38,
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
                    Navigator.of(this.context).pop();
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
      if(imageFile != null){
        Navigator.of(context).push(MaterialPageRoute(builder: (_){
          return EditProfilePicConfirmation(imageFile, imageUrl);
        }));
      }
    } else {
      showDialog(
        context: this.context,
        builder: (ctx) => AlertDialog(
          title: Text("Permission Needed !"),
          content: Text(
            source == ImageSource.camera
                ? 'This App needs to camera access to get profile picture'
                : 'This App needs to gallery access to get profile picture',
          ),
          actions: [
            FlatButton(
              onPressed: () {
                setState(() {
                  Navigator.of(ctx).pop();
                  AppSettings.openAppSettings();
                });
              },
              child: Text(
                "Settings",
                style: TextStyle(color: Colors.black),
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
  }

  buildListTile(Icon icon, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(35)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Colors.white,
            ],
          )),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: icon,
        ),
        title: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }

  getTravelerDetails() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("travelers")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .snapshots(),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );

          var data = snapShot.data;
          imageUrl = data['imageUrl'];
          username = data['username'];
          phone = data['phone'];
          address = data['address'];
          email = data['email'];
          gender = data['gender'];
          birth = data['dateOfBirth'];
          birthDate = DateTime.parse(birth.toDate().toString());
          return Column(
            children: [
              Stack(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(300),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(90)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.45),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        maxRadius: 90,
                        backgroundImage: NetworkImage(imageUrl),
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                          context: this.context, builder: (_) => imageDialog());
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            border: Border.all(),
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 32,
                          )),
                      onTap: () {
                        showModalBottomSheet(
                            context: ctx,
                            builder: (_) {
                              return Container(
                                color: Color(0xFF737373),
                                height: 120,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(this.context).canvasColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                            ),
                                            child: Icon(Icons.image)),
                                        title: Text("Get picture from gallery"),
                                        onTap: () {
                                          getImage(ctx, ImageSource.gallery);
                                        },
                                      ),
                                      ListTile(
                                        leading: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30)),
                                            ),
                                            child: Icon(Icons.camera)),
                                        title: Text("Get picture from camera"),
                                        onTap: () {
                                          getImage(ctx, ImageSource.camera);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 22.0),
                child: Column(
                  children: [
                    buildListTile(Icon(Icons.person), username.toString()),
                    buildListTile(Icon(Icons.email_rounded), email.toString()),
                    buildListTile(Icon(Icons.phone), phone.toString()),
                    buildListTile(Icon(Icons.home), address.toString()),
                    buildListTile(Icon(Icons.date_range),
                        "${birthDate.day}/${birthDate.month}/${birthDate.year}"),
                    buildListTile(
                        Icon(gender == "Male" ? Icons.male : Icons.female),
                        gender),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Profile"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                print("Username1: $username");
                print("Birth date: $birth");
                return EditTravelerProfile(
                  username: username,
                  address: address,
                  email: email,
                  phone: phone,
                  birthDate: birthDate,
                  gender: gender,
                );
              }));
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
          child: Column(
            children: [
              getTravelerDetails(),
            ],
          ),
        ),
      ),
    );
  }
}
