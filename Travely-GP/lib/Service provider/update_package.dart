import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:travely/Registration%20components/error_text.dart';
import 'package:travely/Screens/loading.dart';
import 'package:path/path.dart';
import 'package:travely/Service%20provider/service_provider_home_page.dart';

class UpdatePackage extends StatefulWidget {
  final String packageId, packageName, packageDescription;
  final double packagePrice;
  final List<String> images;
  final startDate, endDate;
  final currencyConverterVal, originalCurrency;
  final categories, numOfTickets;

  const UpdatePackage({
    this.packageId,
    this.packageName,
    this.packageDescription,
    this.packagePrice,
    this.startDate,
    this.endDate,
    this.images,
    this.currencyConverterVal,
    this.originalCurrency,
    this.categories,
    this.numOfTickets,
  });

  @override
  _UpdatePackageState createState() => _UpdatePackageState();
}

class _UpdatePackageState extends State<UpdatePackage> {
  var startDate, endDate;
  var packageNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var priceController = TextEditingController();
  var ticketsController = TextEditingController();
  bool packageNameChecker = false,
      descriptionChecker = false,
      priceChecker = false,
      startDateChecker = false,
      endDateChecker = false,
      imagesChecker = false,
      ticketsNumChecker = false,
      categoriesChecker = false,
      _isLoading = false;
  var foreignTrip = false,
      localTrip = false,
      journeyOverland = false,
      cureTrip = false,
      safari = false,
      studyTrip = false,
      cruise = false,
      mountainTrip = false;
  var egpToUsd, egpToEu;
  var newImageFileUrl;
  var image1, image2, image3, image4, image5, image6, image7;
  List<String> images = [], currencies = ['£ L.E', '\$ US', '€ EU'];
  var package, categories = [], originalCurrency;
  List<Asset> newImages = [];
  List<File> newImagesFiles = [];
  List<String> oldImagesURLs, allImagesURLs;
  var packageName, description, ticketsNumber, price, currencyConverterVal;
  List<bool> deletedImages = [];

  void startDatePicker() {
    showDatePicker(
      context: this.context,
      initialDate: startDate,
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
      initialDate: endDate == null ? startDate : endDate,
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
    if (newImages.length == 0 && oldImagesURLs.length == 0) {
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

  var deletedImagesCounter = 0;

  loadImages() async {
    List<Asset> resultList = List<Asset>();
    try {
      deletedImagesCounter = 0;
      for (int i = 0; i < deletedImages.length; i++)
        if (deletedImages[i] == true) deletedImagesCounter++;

      resultList = await MultiImagePicker.pickImages(
        maxImages: 7 - oldImagesURLs.length + deletedImagesCounter,
        selectedAssets: newImages,
        enableCamera: true,
      );
      setState(() {
        newImages = resultList;
      });
    } catch (e) {
      print(e);
    }
  }

  checkTicketsNum() {
    if (ticketsController.text.trim() == "") {
      setState(() {
        ticketsNumChecker = true;
      });
    } else {
      setState(() {
        ticketsNumChecker = false;
      });

      return !ticketsNumChecker;
    }
  }

  checkCategory(bool isCategory, String category) {
    if (isCategory == true) {
      categories.add(category);
    }
  }

  checkCategories() {
    print("Categories selected are: $categories");

    if (categories.length >= 1) {
      setState(() {
        categoriesChecker = false;
      });
    } else {
      setState(() {
        categoriesChecker = true;
      });
    }
    return !categoriesChecker;
  }

  validateInfo() {
    checkPackageName();
    checkEndDate();
    checkStartDate();
    checkPackageDescription();
    checkPackagePrice();
    checkImageLoader();
    checkCategories();
    checkTicketsNum();

    if (checkPackageName() &&
        checkEndDate() &&
        checkStartDate() &&
        checkPackageDescription() &&
        checkPackagePrice() &&
        checkImageLoader() &&
        checkCategories() &&
        checkTicketsNum()) {
      return true;
    } else {
      return false;
    }
  }

  convertAssetsToFiles() async {
    newImagesFiles = List<File>();
    for (int i = 0; i < newImages.length; i++) {
      var path =
          await FlutterAbsolutePath.getAbsolutePath(newImages[i].identifier);
      print("The path: $path");
      final file = File(path);
      newImagesFiles.add(file);
    }
  }

  Future<String> uploadFile(File imageFile) async {
    String fileName = basename(imageFile.path);
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('Images/').child(fileName);
    print("BOm bOM bom BOM");
    await firebaseStorageRef.putFile(imageFile);
    newImageFileUrl = await firebaseStorageRef.getDownloadURL();
    return newImageFileUrl;
  }

  var finalNewImagesUrls;

  Future<List<String>> uploadFiles() async {
    finalNewImagesUrls =
        await Future.wait(newImagesFiles.map((_image) => uploadFile(_image)));
    print(finalNewImagesUrls);
    return finalNewImagesUrls;
  }

  deleteImage(String imageUrl) async {
    if (imageUrl != null) {
      var firebaseStorageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      await firebaseStorageRef.delete();
    }
  }

  var deletedImagesURLs = [];

  deleteImages() async {
    await Future.wait(deletedImagesURLs.map((_image) => deleteImage(_image)));
  }

  updatePackage() async {
    setState(() {
      _isLoading = true;
    });
    for (int i = 0; i < oldImagesURLs.length; i++) {
      if (deletedImages[i]) {
        deletedImagesURLs.add(oldImagesURLs[i]);
        oldImagesURLs.removeAt(i);
      }
    }
    print("'packageName': ${packageNameController.text.trim()}\n'"
        "price': ${priceController.text.trim()}\n"
        "'description': ${descriptionController.text.trim()}\n"
        "'startDate': $startDate\n"
        "'endDate': $endDate\n"
        "'(new) images': $finalNewImagesUrls\n"
        "'(old) images': $oldImagesURLs\n"
        "'(deleted) images': $deletedImagesURLs\n"
        "'categories': $categories\n");

    convertAssetsToFiles().then((_) {
      uploadFiles().then((_) async {
        deleteImages().then((_) async {
          allImagesURLs = [];
          allImagesURLs = oldImagesURLs + finalNewImagesUrls;
          var packages = FirebaseFirestore.instance.collection("packages");
          return packages
              .doc(widget.packageId)
              .update({
                'packageName': packageNameController.text.trim(),
                'price': double.parse(priceController.text.trim()) /
                    currencyConverterVal,
                'description': descriptionController.text.trim(),
                'startDate': startDate,
                'endDate': endDate,
                'images': allImagesURLs,
                "categories": categories,
                "numOfTickets": int.parse(ticketsController.text.trim()),
              })
              .then((value) {})
              .catchError((e) => print("Cannot be updated: $e"));
        });
      });
    });
  }

  buildCheckBoxListFT(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Foreign Trip"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Foreign Trip"))
            categories.remove("Foreign Trip");
          else
            categories.add("Foreign Trip");
          print(categories);
          foreignTrip = checked;
          print("FT is $foreignTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListLT(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Local Trip"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Local Trip"))
            categories.remove("Local Trip");
          else
            categories.add("Local Trip");
          print(categories);
          localTrip = checked;
          print("LT is $localTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListJO(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Journey Overland"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Journey Overland"))
            categories.remove("Journey Overland");
          else
            categories.add("Journey Overland");
          print(categories);
          journeyOverland = checked;
          print("JO is $journeyOverland");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListCT(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Cure Trip"),
      onChanged: (bool checked) {
        if (categories.contains("Cure Trip"))
          categories.remove("Cure Trip");
        else
          categories.add("Cure Trip");
        print(categories);
        setState(() {
          cureTrip = checked;
          print("CT is $cureTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListSafari(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Safari"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Safari"))
            categories.remove("Safari");
          else
            categories.add("Safari");
          print(categories);
          safari = checked;
          print("Safari is $safari");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListCruise(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Cruise"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Cruise"))
            categories.remove("Cruise");
          else
            categories.add("Cruise");
          print(categories);
          cruise = checked;
          print("Cruise is $cruise");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListMT(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Mountain Trip"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Mountain Trip"))
            categories.remove("Mountain Trip");
          else
            categories.add("Mountain Trip");
          print(categories);
          mountainTrip = checked;
          print("MT is $mountainTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  buildCheckBoxListST(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: categories.contains("Study Trip"),
      onChanged: (bool checked) {
        setState(() {
          if (categories.contains("Study Trip"))
            categories.remove("Study Trip");
          else
            categories.add("Study Trip");
          print(categories);
          studyTrip = checked;
          print("ST is $studyTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  @override
  void initState() {
    super.initState();
    endDate = widget.endDate;
    startDate = widget.startDate;
    categories = widget.categories;
    originalCurrency = widget.originalCurrency;
    currencyConverterVal = widget.currencyConverterVal;
    oldImagesURLs = widget.images;
    packageName = widget.packageName;
    description = widget.packageDescription;
    ticketsNumber = widget.numOfTickets;
    price = widget.packagePrice;

    for (int i = 0; i < oldImagesURLs.length; i++) {
      deletedImages.add(false);
    }
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
                    TextField(
                      controller: packageNameController..text = packageName,
                      decoration: InputDecoration(
                          labelText: "Package Name",
                          hintText: "Enter your package name",
                          prefixIcon: Icon(Icons.card_travel),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide(color: Colors.redAccent))),
                      keyboardType: TextInputType.text,
                      maxLength: 30,
                      onChanged: (newValue) {
                        packageName = newValue;
                      },
                    ),
                    ErrorText(
                      errorText:
                          "Package name should be in range 3 and 30 characters",
                      isVisible: packageNameChecker,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: descriptionController..text = description,
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
                      onChanged: (newValue) {
                        description = newValue;
                      },
                    ),
                    ErrorText(
                      errorText:
                          "Package description should be in range 5 and 250 characters",
                      isVisible: descriptionChecker,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: ticketsController
                        ..text = ticketsNumber.toString(),
                      decoration: InputDecoration(
                          labelText: "Tickets Number",
                          hintText: "Num. of tickets can be reserved",
                          prefixIcon: Icon(Icons.airplane_ticket),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                              borderSide: BorderSide(color: Colors.redAccent))),
                      keyboardType: TextInputType.numberWithOptions(
                          signed: false, decimal: false),
                      onChanged: (newValue) {
                        ticketsNumber = newValue;
                      },
                    ),
                    ErrorText(
                      errorText: "Enter number of available tickets",
                      isVisible: ticketsNumChecker,
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController
                              ..text = (price * currencyConverterVal)
                                  .toStringAsFixed(2),
                            decoration: InputDecoration(
                                labelText: "Price",
                                hintText: "Enter new package price",
                                prefixIcon: Icon(Icons.money),
                                suffix: Text(originalCurrency),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(60),
                                    borderSide:
                                        BorderSide(color: Colors.redAccent))),
                            keyboardType: TextInputType.number,
                            onChanged: (newValue) {
                              price = newValue;
                            },
                          ),
                        ),
                      ],
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
                                  "${DateFormat.yMMMd().format(startDate)}"),
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
                              child: Text(endDate == null
                                  ? "Pick end date"
                                  : "${DateFormat.yMMMd().format(endDate)}"),
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
                    newImages.length >= 1
                        ? GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            children: List.generate(newImages.length, (index) {
                              return AssetThumb(
                                asset: newImages[index],
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
                      children: List.generate(oldImagesURLs.length, (index) {
                        return InkWell(
                          onLongPress: () {
                            if (!deletedImages[index])
                              showAlertDialog(index, "Delete");
                            else
                              showAlertDialog(index, "Return");
                          },
                          child: !deletedImages[index]
                              ? Container(
                                  child: Image.network(oldImagesURLs[index]),
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      child:
                                          Image.network(oldImagesURLs[index]),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.red,
                                              Color.fromRGBO(
                                                  255, 255, 255, 0.0),
                                            ]),
                                      ),
                                    ),
                                    Center(
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 70,
                                      ),
                                    ),
                                  ],
                                ),
                        );
                      }),
                    ),
                    ExpansionTile(
                      textColor: fc,
                      iconColor: fc,
                      title: Text(
                        "Choose the package type",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("You can choose multiple types"),
                      children: [
                        buildCheckBoxListFT(context, "Foreign Trip"),
                        buildCheckBoxListLT(context, "Local Trip"),
                        buildCheckBoxListCT(context, "Cure Trip"),
                        buildCheckBoxListCruise(context, "Cruise"),
                        buildCheckBoxListSafari(context, "Safari"),
                        buildCheckBoxListST(context, "Study Trip"),
                        buildCheckBoxListMT(context, "Mountain Trip"),
                        buildCheckBoxListJO(context, "Journey Overland"),
                      ],
                    ),
                    SizedBox(height: 10),
                    ErrorText(
                      errorText: "Select the package type(s)",
                      isVisible: categoriesChecker,
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => SPHomePage(),
                              ),
                                  (route) => false,
                            );
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

  showAlertDialog(int index, String action) {
    if ((action == "Return" &&
            oldImagesURLs.length - deletedImagesCounter + newImages.length <
                7) ||
        action == "Delete")
      showDialog(
        context: this.context,
        builder: (ctx) => AlertDialog(
          title: Text("$action Provider Request!"),
          content: Text(
              "Are you sure you want to ${action.toLowerCase()} this image?"),
          actions: [
            FlatButton(
              onPressed: () {
                if (action == "Delete") {
                  setState(() {
                    deletedImages[index] = true;
                    deletedImagesCounter++;
                  });
                } else {
                  setState(() {
                    deletedImages[index] = false;
                    deletedImagesCounter--;
                  });
                }
                Navigator.of(ctx).pop();
              },
              child: Text(
                "$action",
                style: TextStyle(
                  color: action == "Delete" ? Colors.red : Colors.green,
                ),
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
    else
      showDialog(
        context: this.context,
        builder: (ctx) => AlertDialog(
          title: Text("Warning!"),
          content: Text("You cannot pick more than 7 Images."),
          actions: [
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
