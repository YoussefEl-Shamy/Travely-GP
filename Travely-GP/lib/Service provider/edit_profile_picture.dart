import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class EditProfilePicConfirmation extends StatefulWidget {
  final imageFile;
  final oldImageUrl;

  const EditProfilePicConfirmation(this.imageFile, this.oldImageUrl);

  @override
  _EditProfilePicConfirmationState createState() =>
      _EditProfilePicConfirmationState();
}

class _EditProfilePicConfirmationState
    extends State<EditProfilePicConfirmation> {
  String imageUrl = "";
  String imageFileUrl = "";

  uploadImage() async {
    File imageFileFinal = (File(widget.imageFile.path));
    String fileName = basename(imageFileFinal.path);
    print("gggggggggggggggggggg ${widget.imageFile.path}");
    Reference firebaseStorageRef =
    FirebaseStorage.instance.ref().child('Images/').child(fileName);
    print("BOm bOM bom BOM");
    await firebaseStorageRef.putFile(imageFileFinal);
    imageFileUrl = await firebaseStorageRef.getDownloadURL();
  }

  updateImageUrl() {
    uploadImage().then((_) {
      FirebaseFirestore.instance
          .collection("service providers")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({"imageUrl": imageFileUrl});
    });
  }

  deleteOldImage() async {
    if (widget.oldImageUrl != null) {
      var firebaseStorageRef =
      FirebaseStorage.instance.refFromURL(widget.oldImageUrl);

      await firebaseStorageRef.delete();
    }
  }

  updateImage() {
    updateImageUrl();
    deleteOldImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Profile Picture"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, right: 10, left: 10),
          child: Column(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(160)),
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
                    radius: 160,
                    backgroundColor: Colors.grey,
                    backgroundImage: widget.imageFile != null
                        ? FileImage(File(widget.imageFile.path))
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Change Profile Picture ?",
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.close),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      updateImage();
                      Navigator.of(context).pop();
                    },
                    child: Icon(Icons.check),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
