import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:intl/intl.dart';
import 'package:travely/Registration%20components/error_text.dart';
import 'package:travely/Registration%20components/text_field.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path/path.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Service%20provider/service_provider_home_page.dart';
import 'package:http/http.dart' as http;

class AddPackage extends StatefulWidget {
  @override
  _AddPackageState createState() => _AddPackageState();
}

class _AddPackageState extends State<AddPackage> {
  Color fc = Color(0xFFf58634);
  var startDate, endDate;
  var packageNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var ticketsController = TextEditingController();
  var priceController = TextEditingController();
  var endDateController = TextEditingController();
  bool packageNameChecker = false,
      descriptionChecker = false,
      priceChecker = false,
      startDateChecker = false,
      endDateChecker = false,
      imagesChecker = false,
      categoriesChecker = false,
      ticketsNumChecker = false,
      _isLoading = false;
  var imageFileUrl;
  var foreignTrip = false,
      localTrip = false,
      journeyOverland = false,
      cureTrip = false,
      safari = false,
      studyTrip = false,
      cruise = false,
      mountainTrip = false;
  var egpToUsd, egpToEu;
  var packageTypeList = [], categories = [];
  List<Asset> images = List<Asset>();

  loadImages() async {
    List<Asset> resultList = List<Asset>();
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 7,
        selectedAssets: images,
        enableCamera: true,
      );
      setState(() {
        images = resultList;
      });
    } catch (e) {
      print(e);
    }
  }

  void startDatePicker() {
    showDatePicker(
      context: this.context,
      initialDate: DateTime.now(),
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

  List<File> imageFiles;

  convertAssetsToFiles() async {
    imageFiles = List<File>();
    for (int i = 0; i < images.length; i++) {
      var path =
          await FlutterAbsolutePath.getAbsolutePath(images[i].identifier);
      print("The path: $path");
      final file = File(path);
      imageFiles.add(file);
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

  var imagesUrls;

  Future<List<String>> uploadFiles() async {
    imagesUrls =
        await Future.wait(imageFiles.map((_image) => uploadFile(_image)));
    print(imagesUrls);
    return imagesUrls;
  }

  addPackage() async {
    setState(() {
      _isLoading = true;
    });
    convertAssetsToFiles().then((_) {
      uploadFiles().then((_) async {
        var id = FirebaseFirestore.instance
            .collection("packages")
            .doc()
            .id
            .toString();
        convertToLE();
        print("The needed ID is here: $id");
        await FirebaseFirestore.instance.collection("packages").doc(id).set({
          "packageId": id,
          "packageName": packageNameController.text.trim(),
          "startDate": startDate,
          "endDate": endDate,
          "rate": 0,
          "price": priceDouble,
          "images": imagesUrls,
          "description": descriptionController.text.trim(),
          "organizerId": FirebaseAuth.instance.currentUser.uid,
          "categories": categories,
          "originalCurrency": initVal,
          "numOfTickets": int.parse(ticketsController.text.trim()),
          "currencyConverterVal": initVal == "\$ US"
              ? egpToUsd
              : initVal == "€ EU"
                  ? egpToEu
                  : 1.0,
        });
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
        descriptionController.text.length > 300) {
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
    if (images.length == 0) {
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

  checkCategory(bool isCategory, String category) {
    if (isCategory == true) {
      categories.add(category);
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

  checkCategories() {
    categories.clear();
    checkCategory(foreignTrip, "Foreign Trip");
    checkCategory(localTrip, "Local Trip");
    checkCategory(cureTrip, "Cure Trip");
    checkCategory(cruise, "Cruise");
    checkCategory(safari, "Safari");
    checkCategory(studyTrip, "Study Trip");
    checkCategory(mountainTrip, "Mountain Trip");
    checkCategory(journeyOverland, "Journey Overland");

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

  buildCheckBoxListFT(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: foreignTrip,
      onChanged: (bool checked) {
        setState(() {
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
      value: localTrip,
      onChanged: (bool checked) {
        setState(() {
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
      value: journeyOverland,
      onChanged: (bool checked) {
        setState(() {
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
      value: cureTrip,
      onChanged: (bool checked) {
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
      value: safari,
      onChanged: (bool checked) {
        setState(() {
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
      value: cruise,
      onChanged: (bool checked) {
        setState(() {
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
      value: mountainTrip,
      onChanged: (bool checked) {
        setState(() {
          mountainTrip = checked;
          print("MT is $mountainTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  double priceDouble;

  convertToLE() {
    var priceString = priceController.text.trim();
    String finalPriceString = double.parse(priceString).toStringAsFixed(2);
    priceDouble = double.parse(finalPriceString);
    if (initVal == "\$ US") {
      print("Dollar");
      priceDouble = priceDouble / eurCurrencies[0];
      var usd = priceDouble;
      print("USD: $usd");
      priceDouble = priceDouble * eurCurrencies[1];
    } else if (initVal == "€ EU") {
      print("EURO");
      priceDouble = priceDouble * eurCurrencies[1];
    }
    print("Final final final price: $priceDouble");
    egpToUsd = eurCurrencies[0] / eurCurrencies[1];
    egpToEu = 1 / eurCurrencies[1];
    print("EGP_USD Result: ${eurCurrencies[0] / eurCurrencies[1]}");
    print("EGP_EU Result: ${1 / eurCurrencies[1]}");
  }

  buildCheckBoxListST(BuildContext context, String title) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: studyTrip,
      onChanged: (bool checked) {
        setState(() {
          studyTrip = checked;
          print("ST is $studyTrip");
        });
      },
      activeColor: Theme.of(context).primaryColor,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  String initVal = '£ L.E';
  var currencies = ['£ L.E', '\$ US', '€ EU'];
  var eurCurrencies = [];

  loadCurrencies() async {
    String uri =
        "http://api.exchangeratesapi.io/v1/latest?access_key=cae78e3094c4e5c4c75b04825e5d5a93&symbols=USD,EGP&format=1";
    var response = await http.get(Uri.parse(Uri.encodeFull(uri)),
        headers: {"Accept": "application/json"});
    var responseBody = json.decode(response.body) as Map<dynamic, dynamic>;
    print("$responseBody");
    responseBody['rates'].forEach((k, v) => eurCurrencies.add(v));
    print(eurCurrencies);
  }

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text("Add New Package"),
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
                    ),
                    ErrorText(
                      errorText:
                          "Package name should not be less than 3 characters",
                      isVisible: packageNameChecker,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: descriptionController,
                      maxLength: 300,
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
                          "Description should not be less than 5 characters",
                      isVisible: descriptionChecker,
                    ),
                    SizedBox(height: 15),
                    MyTextField(
                      ticketsController,
                      "Tickets Number",
                      "Num. of tickets can be reserved",
                      Icon(Icons.airplane_ticket),
                      TextInputType.numberWithOptions(
                          signed: false, decimal: false),
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
                          child: MyTextField(
                            priceController,
                            "Price of the ticket",
                            "Package ticket price",
                            Icon(Icons.add),
                            TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 7),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 17),
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                          ),
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            value: initVal,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Theme.of(context).accentColor,
                            ),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 17,
                            ),
                            underline: Container(
                              height: 2,
                              color: Theme.of(context).accentColor,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                initVal = newValue;
                                print(initVal);
                              });
                            },
                            items: currencies
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    ErrorText(
                      errorText: "Package price is required",
                      isVisible: priceChecker,
                    ),
                    SizedBox(height: 15),
                    if (startDate == null)
                      InkWell(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFF007965),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(15),
                          child: startDate == null
                              ? Center(
                                  child: Text(
                                    "Pick package start date",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : Text(
                                  "${DateFormat.yMMMd().format(startDate)}",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          startDatePicker();
                        },
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            if (startDate != null)
                              InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF007965),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(15),
                                  child: startDate == null
                                      ? Text(
                                          "Pick package start date",
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : Text(
                                          "${DateFormat.yMMMd().format(startDate)}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  startDatePicker();
                                },
                              ),
                            if (startDate == null)
                              ErrorText(
                                errorText: "Enter package start date",
                                isVisible: startDateChecker,
                              ),
                          ],
                        ),
                        startDate != null
                            ? SizedBox(
                                width: 15,
                              )
                            : Container(),
                        startDate != null
                            ? Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: RaisedButton(
                                      padding: EdgeInsets.all(15),
                                      color: Color(0xFF007965),
                                      textColor: Colors.white,
                                      child: endDate == null
                                          ? Text("Pick package end date")
                                          : Text(
                                              "${DateFormat.yMMMd().format(endDate)}"),
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        endDatePicker();
                                      },
                                    ),
                                  ),
                                  if (endDate == null)
                                    ErrorText(
                                      errorText: "Enter package end date",
                                      isVisible: endDateChecker,
                                    ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      width: double.infinity,
                      child: RaisedButton.icon(
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
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    images.length >= 1
                        ? GridView.count(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 3,
                            children: List.generate(images.length, (index) {
                              return AssetThumb(
                                asset: images[index],
                                width: 300,
                                height: 300,
                              );
                            }),
                          )
                        : ErrorText(
                            errorText: "Choose some images for the package",
                            isVisible: imagesChecker,
                          ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: FlatButton(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Submit package",
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
                            addPackage().then((_) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      SPHomePage(checker: true,),
                                ),
                                (route) => false,
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
