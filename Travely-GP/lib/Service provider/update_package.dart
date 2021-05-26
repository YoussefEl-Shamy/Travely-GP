import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:travely/Registration%20components/error_text.dart';
import 'package:travely/Registration%20components/text_field.dart';
import 'package:travely/Screens/loading.dart';
import 'package:path/path.dart';

class UpdatePackage extends StatefulWidget {
  final String packageId, packageName, packageDescription;
  final double packagePrice;
  final List<String> images;
  final startDate, endDate;

  const UpdatePackage(
      {this.packageId,
      this.packageName,
      this.packageDescription,
      this.packagePrice,
      this.startDate,
      this.endDate,
      this.images});

  @override
  _UpdatePackageState createState() => _UpdatePackageState();
}

class _UpdatePackageState extends State<UpdatePackage> {
  var startDate, endDate;
  var packageNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var priceController = TextEditingController();
  bool packageNameChecker = false,
      descriptionChecker = false,
      priceChecker = false,
      startDateChecker = false,
      endDateChecker = false,
      imagesChecker = false,
      _isLoading = false;
  var imageFileUrl;
  var image1, image2, image3, image4, image5, image6, image7;
  List<String> images = [];
  var package;
  List<Asset> addedImages = List<Asset>();

  void startDatePicker() {
    showDatePicker(
      context: this.context,
      initialDate: widget.startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 3),
    ).then((value) {
      if (value == null) {
        return 0;
      }
      setState(() {
        startDate = value;
        endDate = null;
      });
    });
  }

  void endDatePicker() {
    showDatePicker(
      context: this.context,
      initialDate: startDate,
      firstDate: startDate,
      lastDate: DateTime(DateTime.now().year + 3),
    ).then((value) {
      if (value == null) {
        return 0;
      }
      setState(() {
        endDate = value;
      });
    });
  }

  checkPackageName() {
    if (packageNameController.text == "" ||
        packageNameController.text.length < 3 ||
        packageNameController.text.length > 30) {
      setState(() {
        packageNameChecker = true;
      });
    } else {
      setState(() {
        packageNameChecker = false;
      });
    }
    return !packageNameChecker;
  }

  checkPackageDescription() {
    if (descriptionController.text == "" ||
        descriptionController.text.length < 5 ||
        descriptionController.text.length > 250) {
      setState(() {
        descriptionChecker = true;
      });
    } else {
      setState(() {
        descriptionChecker = false;
      });
    }
    return !descriptionChecker;
  }

  checkPackagePrice() {
    if (priceController.text == "" || priceController.text.length < 1) {
      setState(() {
        priceChecker = true;
      });
    } else {
      setState(() {
        priceChecker = false;
      });
    }
    return !priceChecker;
  }

  checkStartDate() {
    if (startDate == null) {
      setState(() {
        startDateChecker = true;
      });
    } else {
      setState(() {
        startDateChecker = false;
      });
    }
    return !startDateChecker;
  }

  checkEndDate() {
    if (endDate == null) {
      setState(() {
        endDateChecker = true;
      });
    } else {
      setState(() {
        endDateChecker = false;
      });
    }
    return !endDateChecker;
  }

  checkImageLoader() {
    if (addedImages.length == 0) {
      setState(() {
        imagesChecker = true;
      });
    } else {
      setState(() {
        imagesChecker = false;
      });
    }

    return !imagesChecker;
  }

  loadImages() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 7-widget.images.length,
        selectedAssets: addedImages,
        enableCamera: true,
      );
      setState(() {
        addedImages = resultList;
      });
    } catch (e) {
      print(e);
    }
  }

  validateInfo() {
    checkPackageName();
    checkEndDate();
    checkStartDate();
    checkPackageDescription();
    checkPackagePrice();
    checkImageLoader();

    if (checkPackageName() &&
        checkEndDate() &&
        checkStartDate() &&
        checkPackageDescription() &&
        checkPackagePrice() &&
        checkImageLoader()) {
      return true;
    } else {
      return false;
    }
  }

  List<File> addedImageFiles;

  convertAssetsToFiles() async {
    addedImageFiles = List<File>();
    for (int i = 0; i < addedImages.length; i++) {
      var path =
          await FlutterAbsolutePath.getAbsolutePath(addedImages[i].identifier);
      print("The path: $path");
      final file = File(path);
      addedImageFiles.add(file);
    }
  }

  Future<String> uploadFile(File imageFile) async {
    String fileName = basename(imageFile.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Images/').child(fileName);
    print("BOm bOM bom BOM");
    await firebaseStorageRef.putFile(imageFile);
    imageFileUrl = await firebaseStorageRef.getDownloadURL();
    return imageFileUrl;
  }

  var finalImagesUrls;

  Future<List<String>> uploadFiles() async {
    finalImagesUrls =
        await Future.wait(addedImageFiles.map((_image) => uploadFile(_image)));
    print(finalImagesUrls);
    return finalImagesUrls;
  }

  updatePackage() async {
    convertAssetsToFiles().then((_) {
      uploadFiles().then((_) async {
        var packages = FirebaseFirestore.instance.collection("packages");
        return packages
            .doc(widget.packageId)
            .update({
              'packageName': packageNameController.text.trim(),
              'price': priceController.text.trim(),
              'description': descriptionController.text.trim(),
              'startDate': startDate,
              'endDate': endDate,
              'images': finalImagesUrls,
            })
            .then((value) {})
            .catchError((e) => print("Cannot be updated: $e"));
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.packageName),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    MyTextField(
                      packageNameController,
                      "Package name",
                      "Enter your package name",
                      Icon(Icons.card_travel),
                      TextInputType.text,
                      inputMaxLength: 30,
                      initVal: widget.packageName,
                    ),
                    ErrorText(
                      errorText:
                          "Package name should be in range 3 and 30 characters",
                      isVisible: packageNameChecker,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: descriptionController
                        ..text = widget.packageDescription,
                      maxLength: 250,
                      decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Enter package description",
                          prefixIcon: Icon(Icons.description_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.redAccent))),
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                    ),
                    ErrorText(
                      errorText:
                          "Package description should be in range 5 and 250 characters",
                      isVisible: descriptionChecker,
                    ),
                    SizedBox(height: 15),
                    MyTextField(
                      priceController,
                      "Price",
                      "Enter package price",
                      Icon(Icons.attach_money),
                      TextInputType.number,
                      initVal: widget.packagePrice.toString(),
                    ),
                    ErrorText(
                      errorText: "Package price is required",
                      isVisible: priceChecker,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            RaisedButton(
                              padding: EdgeInsets.all(15),
                              color: Color(0xFF007965),
                              textColor: Colors.white,
                              child: Text(
                                  "${DateFormat.yMMMd().format(widget.startDate)}"),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                startDatePicker();
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          children: [
                            RaisedButton(
                              padding: EdgeInsets.all(15),
                              color: Color(0xFF007965),
                              textColor: Colors.white,
                              child: Text(
                                  "${DateFormat.yMMMd().format(widget.endDate)}"),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                endDatePicker();
                              },
                            ),
                            ErrorText(
                              errorText: "Enter package end date",
                              isVisible: endDateChecker,
                            ),
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    RaisedButton.icon(
                        padding: EdgeInsets.all(12),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          loadImages();
                        },
                        splashColor: Theme.of(context).accentColor,
                        color: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.add_photo_alternate_sharp,
                          color: Colors.white,
                        ),
                        label: Text(
                          "Pick images for the package",
                          style: TextStyle(color: Colors.white),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    addedImages.length >= 1
                        ? GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            children:
                                List.generate(addedImages.length, (index) {
                              return AssetThumb(
                                asset: addedImages[index],
                                width: 300,
                                height: 300,
                              );
                            }),
                          )
                        : ErrorText(
                            errorText: "Choose some images for the package",
                            isVisible: imagesChecker,
                          ),
                    SizedBox(height: 15),
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      children:
                      List.generate(widget.images.length, (index) {
                        return Container(
                          child: Image.network(widget.images[index]),
                        );
                      }),
                    ),
                    SizedBox(height: 20,),
                    FlatButton(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            "Save Changes",
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
                        FocusScope.of(context).unfocus();
                        if (validateInfo()) {
                          setState(() {
                            _isLoading = true;
                          });
                          updatePackage().then((_) {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.of(context).pop();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
