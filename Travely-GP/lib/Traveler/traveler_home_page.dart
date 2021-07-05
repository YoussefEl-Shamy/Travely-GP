import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/un_rated_provider.dart';
import 'package:travely/Screens/drawer_traveler.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Traveler/package_item.dart';
import 'package:travely/Providers/searching_provider.dart';
import 'package:travely/Traveler/recommended_travels.dart';
import 'package:travely/Traveler/traveler_profile.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  var searchController = TextEditingController();
  Color fc = Color(0xFFf58634);
  bool checker = false;
  int _currentIndex = 0;
  var snapshotDocs, searchVal = "", resultsCounter = 0;
  var sProviderFalse, sProviderTrue;
  String imageUrl = "";
  var userId = FirebaseAuth.instance.currentUser.uid;
  var unRatedNum, _isLoading = false;
  var packagesIDs = [];
  var finishedPackagesIDs = [];

  String initValPackageTypes = 'None';
  List<String> packageTypes = [
    "None",
    "Foreign Trip",
    "Local Trip",
    "Cure Trip",
    "Cruise",
    "Safari",
    "Study Trip",
    "Mountain Trip",
    "Journey Overland"
  ];

  String initValCurrencies = 'None';
  List<String> currencies = ["None", '£ L.E', '\$ US', '€ EU'];

  String initValPriceRanges = 'None';
  List<String> priceRanges = [
    "None",
    "Less that 10",
    "10 - 50",
    "50 - 100",
    "100 - 200",
    "200 - 300",
    "300 - 500",
    "500 - 700",
    "700 - 1000",
    "1000 - 1200",
    "1200 - 1500",
    "1500 - 2000",
    "2000 to up"
  ];

  getPackagesIDs() async {
    await FirebaseFirestore.instance
        .collection('travelersPackages')
        .where("travelerId", isEqualTo: userId)
        .get()
        .then(
      (QuerySnapshot snapshot) {
        List<DocumentSnapshot> docs = snapshot.docs;
        for (int i = 0; i < docs.length; i++) {
          var docId = docs[i]['packageId'];
          print("Doc ID: $docId");
          packagesIDs.add(docId);
          print("package IDs length: ${packagesIDs.length}");
        }
      },
    );
  }

  bool checkDocExistence;

  getDoc(String packageId) async {
    print("getDoc");
    snapshotDocs = await FirebaseFirestore.instance
        .collection("packages")
        .doc(packageId)
        .get();
  }

  checkDoc(String packageId) async {
    print("checkDoc");
    print("snapShotDocs: $snapshotDocs");
    DocumentSnapshot d;
    await getDoc(packageId).then((_) {
      if (!snapshotDocs.exists) {
        setState(() {
          checkDocExistence = false;
        });
      } else {
        setState(() {
          checkDocExistence = true;
        });
      }
      print("checkDocExistence: $checkDocExistence");
    });
  }

  moveToUnRated({
    String organizerId,
    String packageId,
    double rate,
    String travelerId,
    int numOfTickets,
    String packageName,
    double price,
    String description,
    categories,
  }) async {
    var id = FirebaseFirestore.instance
        .collection("unRatedTravels")
        .doc()
        .id
        .toString();
    await FirebaseFirestore.instance.collection("unRatedTravels").doc(id).set({
      "organizerId": organizerId,
      "packageId": packageId,
      "rate": rate,
      "ticketId": id,
      "travelerId": travelerId,
      "numOfTickets": numOfTickets,
      "packageName": packageName,
      "description": description,
      "price": price,
      "categories": categories,
    });
  }

  deleteTravelerTicket() {
    getPackagesIDs().then((_) {
      print("package IDs length: ${packagesIDs.length}");
      for (int i = 0; i < packagesIDs.length; i++) {
        checkDoc(packagesIDs[i]).then((_) {
          print("checker 1: $checkDocExistence");
          print("checker 2: $checker");
          print("package number ${i + 1}: ${packagesIDs[i]}");
          if (checkDocExistence && checker) {
            print("if condition");
            FirebaseFirestore.instance
                .collection('packages')
                .doc(packagesIDs[i])
                .get()
                .then((value) {
              var docEndDate = value['endDate'];
              var endDate = docEndDate.toDate();
              print("end date: $endDate");
              if (DateTime.now().difference(endDate) > Duration(days: 1)) {
                FirebaseFirestore.instance
                    .collection("travelersPackages")
                    .where("packageId", isEqualTo: packagesIDs[i])
                    .where("travelerId", isEqualTo: userId)
                    .get()
                    .then((value) {
                  value.docs.forEach((element) {
                    var organizerId = element['organizerId'];
                    var packageId = element['packageId'];
                    var rate = element['rate'];
                    var ticketId = element['ticketId'];
                    var travelerId = element['travelerId'];
                    var numOfTickets = element['numOfTickets'];
                    var packageName = element['packageName'];
                    var categories = element['categories'];
                    var price = element['price'];
                    var description = element['description'];
                    moveToUnRated(
                            numOfTickets: numOfTickets,
                            organizerId: organizerId,
                            packageId: packageId,
                            packageName: packageName,
                            rate: rate,
                            travelerId: travelerId,
                            categories: categories,
                            price: price,
                            description: description)
                        .then((_) {
                      FirebaseFirestore.instance
                          .collection("travelersPackages")
                          .doc(element.id)
                          .delete();
                    });
                  });
                });
                FirebaseFirestore.instance
                    .collection("travelers")
                    .doc(userId)
                    .get()
                    .then((value) async {
                  var currentUnRatedNum = value['unRatedNum'];
                  print("$currentUnRatedNum..");
                  await FirebaseFirestore.instance
                      .collection("travelers")
                      .doc(userId)
                      .update({"unRatedNum": ++currentUnRatedNum});
                });
                print("end date after filtering: $endDate");
              }
            });
          } else {
            print("delete from else");
            FirebaseFirestore.instance
                .collection("travelersPackages")
                .where("packageId", isEqualTo: packagesIDs[i])
                .where("travelerId", isEqualTo: userId)
                .get()
                .then((value) {
              value.docs.forEach((element) {
                FirebaseFirestore.instance
                    .collection("travelersPackages")
                    .doc(element.id)
                    .delete();
              });
            });
            FirebaseFirestore.instance
                .collection("travelers")
                .doc(userId)
                .get()
                .then((value) async {
              var currentUnRatedNum = value['unRatedNum'];
              print("$currentUnRatedNum..");
              await FirebaseFirestore.instance
                  .collection("travelers")
                  .doc(userId)
                  .update({"unRatedNum": ++currentUnRatedNum});
            });
          }
        });
      }
      getNumOfUnRated();
    });
  }

  getDocs() async {
    snapshotDocs =
        await FirebaseFirestore.instance.collection("packages").get();
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

  getNumOfUnRated() {
    setState(() {
      _isLoading = true;
    });
    FirebaseFirestore.instance
        .collection('travelers')
        .doc(userId)
        .get()
        .then((val) {
      unRatedNum = val.get('unRatedNum');
      Provider.of<UnRatedProvider>(context, listen: false)
          .setUnRatedNum(unRatedNum);
    });
    setState(() {
      _isLoading = false;
    });
    Provider.of<UnRatedProvider>(context, listen: false)
        .setUnRatedNum(unRatedNum);
  }

  showFiltersDialog() {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Packages Filter"),
        content: Container(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Price Range"),
                  Text("Currency"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).accentColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: initValPriceRanges,
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Theme.of(context).accentColor,
                      ),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).accentColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          initValPriceRanges = newValue;
                          print(initValPriceRanges);
                          resultsCounter = 0;
                        });
                        Navigator.of(context).pop();
                        showFiltersDialog();
                      },
                      items: priceRanges
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).accentColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: Colors.white,
                      value: initValCurrencies,
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Theme.of(context).accentColor,
                      ),
                      iconSize: 24,
                      elevation: 16,
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      underline: Container(
                        height: 2,
                        color: Theme.of(context).accentColor,
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          initValCurrencies = newValue;
                          print(initValCurrencies);
                          resultsCounter = 0;
                        });
                        Navigator.of(context).pop();
                        showFiltersDialog();
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
              SizedBox(height: 30),
              Text("Category"),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).accentColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: initValPackageTypes,
                  icon: Icon(
                    Icons.arrow_downward,
                    color: Theme.of(context).accentColor,
                  ),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).accentColor,
                  ),
                  onChanged: (String newValue) {
                    setState(() {
                      initValPackageTypes = newValue;
                      print(initValPackageTypes);
                      resultsCounter = 0;
                    });
                    Navigator.of(context).pop();
                    showFiltersDialog();
                  },
                  items: packageTypes
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
        ),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              "Done",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkCollection();
    deleteTravelerTicket();
  }

  @override
  void dispose() {
    searchController.text = "";
    searchVal = "";
    if (sProviderFalse.isSearching == true)
      sProviderTrue.setSearch(sProviderFalse.isSearching);
    super.dispose();
  }

  setRememberMe() async {
    SharedPreferences rememberMePreference =
        await SharedPreferences.getInstance();
    rememberMePreference.setBool("rememberMe", false);
  }

  double firstBoundary, lastBoundary;

  getBoundariesOfPriceRange() {
    if (initValPriceRanges != "None") {
      if (initValPriceRanges == "Less that 10") {
        lastBoundary = 10;
      } else if (initValPriceRanges == "10 - 50") {
        firstBoundary = 10;
        lastBoundary = 50;
      } else if (initValPriceRanges == "50 - 100") {
        firstBoundary = 50;
        lastBoundary = 100;
      } else if (initValPriceRanges == "100 - 200") {
        firstBoundary = 100;
        lastBoundary = 200;
      } else if (initValPriceRanges == "200 - 300") {
        firstBoundary = 200;
        lastBoundary = 300;
      } else if (initValPriceRanges == "300 - 500") {
        firstBoundary = 300;
        lastBoundary = 500;
      } else if (initValPriceRanges == "500 - 700") {
        firstBoundary = 500;
        lastBoundary = 700;
      } else if (initValPriceRanges == "700 - 1000") {
        firstBoundary = 700;
        lastBoundary = 1000;
      } else if (initValPriceRanges == "1000 - 1200") {
        firstBoundary = 1000;
        lastBoundary = 1200;
      } else if (initValPriceRanges == "1200 - 1500") {
        firstBoundary = 1200;
        lastBoundary = 1500;
      } else if (initValPriceRanges == "1500 - 2000") {
        firstBoundary = 1500;
        lastBoundary = 2000;
      } else if (initValPriceRanges == "2000 to up") {
        firstBoundary = 2000;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    sProviderFalse = Provider.of<SearchingProvider>(context, listen: false);
    sProviderTrue = Provider.of<SearchingProvider>(context, listen: true);
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: _currentIndex == 0
                  ? sProviderFalse.isSearching
                      ? TextField(
                          cursorColor: Colors.white,
                          autofocus: true,
                          controller: searchController,
                          onChanged: (value) {
                            setState(() {
                              searchVal = value;
                            });
                            setState(() {
                              resultsCounter = 0;
                            });
                          },
                          style: TextStyle(color: Colors.white, fontSize: 17),
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3),
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            hintText: ("Search for package"),
                            hintStyle: TextStyle(color: Colors.white60),
                          ),
                        )
                      : Text("Travel Packages")
                  : Text("Recommended Packages"),
              actions: <Widget>[
                _currentIndex == 0
                    ? sProviderFalse.isSearching
                        ? IconButton(
                            icon: Icon(Icons.cancel),
                            onPressed: () {
                              searchController.text = "";
                              searchVal = "";
                              sProviderTrue
                                  .setSearch(sProviderFalse.isSearching);
                            },
                          )
                        : IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              sProviderTrue
                                  .setSearch(sProviderFalse.isSearching);
                            },
                          )
                    : Container(),
                IconButton(
                  onPressed: () {
                    showFiltersDialog();
                  },
                  icon: Icon(Icons.filter_list_alt),
                )
              ],
            ),
            body: _currentIndex == 1
                ? RecommendedTravels()
                : checker
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('packages')
                            .orderBy("startDate", descending: true)
                            .snapshots(),
                        builder: (ctx, snapShot) {
                          getBoundariesOfPriceRange();
                          if (snapShot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          final docs = snapShot.data.docs;
                          return ListView.builder(
                            itemBuilder: (ctx, index) {
                              if (docs[index]['packageName']
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchVal.toLowerCase()) ||
                                  docs[index]['description']
                                      .toString()
                                      .toLowerCase()
                                      .contains(searchVal.toLowerCase())) {
                                var realPrice0 = docs[index]['price'] *
                                    docs[index]['currencyConverterVal'];
                                String realPriceString =
                                    realPrice0.toStringAsFixed(2);
                                var realPrice =
                                    double.parse(realPriceString);
                                if (initValCurrencies != "None" &&
                                    initValPriceRanges == "None" &&
                                    initValPackageTypes == "None") {
                                  if (docs[index]['originalCurrency']
                                          .toString()
                                          .toLowerCase() ==
                                      initValCurrencies.toLowerCase()) {
                                    print("Results Counter: $resultsCounter");
                                    return PackageItem(
                                      packageId: docs[index]['packageId'],
                                      organizerId: docs[index]['organizerId'],
                                      packageName: docs[index]['packageName'],
                                      imageUrl: docs[index]['images'][0],
                                      description: docs[index]['description'],
                                      price: docs[index]['price'],
                                      originalCurrency: docs[index]
                                          ['originalCurrency'],
                                      currencyConverterVal: docs[index]
                                          ['currencyConverterVal'],
                                      index: index,
                                      searchVal: searchVal,
                                      categories: docs[index]['categories'],
                                    );
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else if (initValPriceRanges != "None" &&
                                    initValCurrencies == "None" &&
                                    initValPackageTypes == "None") {
                                  print("firstBoundary: $firstBoundary");
                                  print("lastBoundary: $lastBoundary");
                                  print("realPrice: $realPrice");
                                  if (firstBoundary == null &&
                                      lastBoundary != null) {
                                    if (realPrice <= lastBoundary) {
                                      return PackageItem(
                                        packageId: docs[index]['packageId'],
                                        organizerId: docs[index]['organizerId'],
                                        packageName: docs[index]['packageName'],
                                        imageUrl: docs[index]['images'][0],
                                        description: docs[index]['description'],
                                        price: docs[index]['price'],
                                        originalCurrency: docs[index]
                                            ['originalCurrency'],
                                        currencyConverterVal: docs[index]
                                            ['currencyConverterVal'],
                                        index: index,
                                        searchVal: searchVal,
                                        categories: docs[index]['categories'],
                                      );
                                    } else {
                                      if (resultsCounter <= docs.length)
                                        resultsCounter++;

                                      if (resultsCounter == docs.length)
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 35),
                                            child: Text("No results found"),
                                          ),
                                        );
                                      return Container();
                                    }
                                  } else if (firstBoundary != null &&
                                      lastBoundary != null) {
                                    if (firstBoundary <= realPrice &&
                                        realPrice <= lastBoundary) {
                                      return PackageItem(
                                        packageId: docs[index]['packageId'],
                                        organizerId: docs[index]['organizerId'],
                                        packageName: docs[index]['packageName'],
                                        imageUrl: docs[index]['images'][0],
                                        description: docs[index]['description'],
                                        price: docs[index]['price'],
                                        originalCurrency: docs[index]
                                            ['originalCurrency'],
                                        currencyConverterVal: docs[index]
                                            ['currencyConverterVal'],
                                        index: index,
                                        searchVal: searchVal,
                                        categories: docs[index]['categories'],
                                      );
                                    } else {
                                      if (resultsCounter <= docs.length)
                                        resultsCounter++;

                                      if (resultsCounter == docs.length)
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 35),
                                            child: Text("No results found"),
                                          ),
                                        );
                                      return Container();
                                    }
                                  } else if (firstBoundary != null &&
                                      lastBoundary == null) {
                                    if (firstBoundary >= realPrice) {
                                      return PackageItem(
                                        packageId: docs[index]['packageId'],
                                        organizerId: docs[index]['organizerId'],
                                        packageName: docs[index]['packageName'],
                                        imageUrl: docs[index]['images'][0],
                                        description: docs[index]['description'],
                                        price: docs[index]['price'],
                                        originalCurrency: docs[index]
                                            ['originalCurrency'],
                                        currencyConverterVal: docs[index]
                                            ['currencyConverterVal'],
                                        index: index,
                                        searchVal: searchVal,
                                        categories: docs[index]['categories'],
                                      );
                                    } else {
                                      if (resultsCounter <= docs.length)
                                        resultsCounter++;

                                      if (resultsCounter == docs.length)
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 35),
                                            child: Text("No results found"),
                                          ),
                                        );
                                      return Container();
                                    }
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else if (initValPackageTypes != "None" &&
                                    initValPriceRanges == "None" &&
                                    initValCurrencies == "None") {
                                  if (docs[index]["categories"]
                                      .contains(initValPackageTypes)) {
                                    return PackageItem(
                                      packageId: docs[index]['packageId'],
                                      organizerId: docs[index]['organizerId'],
                                      packageName: docs[index]['packageName'],
                                      imageUrl: docs[index]['images'][0],
                                      description: docs[index]['description'],
                                      price: docs[index]['price'],
                                      originalCurrency: docs[index]
                                          ['originalCurrency'],
                                      currencyConverterVal: docs[index]
                                          ['currencyConverterVal'],
                                      index: index,
                                      searchVal: searchVal,
                                      categories: docs[index]['categories'],
                                    );
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else if (initValCurrencies != "None" &&
                                    initValPriceRanges != "None" &&
                                    initValPackageTypes != "None") {
                                  if (docs[index]['originalCurrency']
                                              .toString()
                                              .toLowerCase() ==
                                          initValCurrencies.toLowerCase() &&
                                      docs[index]["categories"]
                                          .contains(initValPackageTypes)) {
                                    if (firstBoundary == null &&
                                        lastBoundary != null) {
                                      if (realPrice <= lastBoundary) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else if (firstBoundary != null &&
                                        lastBoundary != null) {
                                      if (firstBoundary <= realPrice &&
                                          realPrice <= lastBoundary) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else if (firstBoundary != null &&
                                        lastBoundary == null) {
                                      if (firstBoundary >= realPrice) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else {
                                      if (resultsCounter <= docs.length)
                                        resultsCounter++;

                                      if (resultsCounter == docs.length)
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 35),
                                            child: Text("No results found"),
                                          ),
                                        );
                                      return Container();
                                    }
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else if (initValCurrencies != "None" &&
                                    initValPriceRanges != "None" &&
                                    initValPackageTypes == "None") {
                                  if (docs[index]['originalCurrency']
                                          .toString()
                                          .toLowerCase() ==
                                      initValCurrencies.toLowerCase()) {
                                    if (firstBoundary == null &&
                                        lastBoundary != null) {
                                      if (realPrice <= lastBoundary) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else if (firstBoundary != null &&
                                        lastBoundary != null) {
                                      if (firstBoundary <= realPrice &&
                                          realPrice <= lastBoundary) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else if (firstBoundary != null &&
                                        lastBoundary == null) {
                                      if (firstBoundary >= realPrice) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else {
                                      if (resultsCounter <= docs.length)
                                        resultsCounter++;

                                      if (resultsCounter == docs.length)
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 35),
                                            child: Text("No results found"),
                                          ),
                                        );
                                      return Container();
                                    }
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else if (initValCurrencies != "None" &&
                                    initValPriceRanges == "None" &&
                                    initValPackageTypes != "None") {
                                  if (docs[index]["categories"]
                                          .contains(initValPackageTypes) &&
                                      docs[index]["originalCurrency"]
                                              .toLowerCase() ==
                                          initValCurrencies.toLowerCase()) {
                                    return PackageItem(
                                      packageId: docs[index]['packageId'],
                                      organizerId: docs[index]['organizerId'],
                                      packageName: docs[index]['packageName'],
                                      imageUrl: docs[index]['images'][0],
                                      description: docs[index]['description'],
                                      price: docs[index]['price'],
                                      originalCurrency: docs[index]
                                      ['originalCurrency'],
                                      currencyConverterVal: docs[index]
                                      ['currencyConverterVal'],
                                      index: index,
                                      searchVal: searchVal,
                                      categories: docs[index]['categories'],
                                    );
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else if (initValCurrencies == "None" &&
                                    initValPriceRanges != "None" &&
                                    initValPackageTypes != "None") {
                                  if (docs[index]["categories"]
                                      .contains(initValPackageTypes)) {
                                    if (firstBoundary == null &&
                                        lastBoundary != null) {
                                      if (realPrice <= lastBoundary) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                          actor: "traveler",
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else if (firstBoundary != null &&
                                        lastBoundary != null) {
                                      if (firstBoundary <= realPrice &&
                                          realPrice <= lastBoundary) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else if (firstBoundary != null &&
                                        lastBoundary == null) {
                                      if (firstBoundary >= realPrice) {
                                        return PackageItem(
                                          packageId: docs[index]['packageId'],
                                          organizerId: docs[index]
                                              ['organizerId'],
                                          packageName: docs[index]
                                              ['packageName'],
                                          imageUrl: docs[index]['images'][0],
                                          description: docs[index]
                                              ['description'],
                                          price: docs[index]['price'],
                                          originalCurrency: docs[index]
                                              ['originalCurrency'],
                                          currencyConverterVal: docs[index]
                                              ['currencyConverterVal'],
                                          index: index,
                                          searchVal: searchVal,
                                          categories: docs[index]['categories'],
                                        );
                                      } else {
                                        if (resultsCounter <= docs.length)
                                          resultsCounter++;

                                        if (resultsCounter == docs.length)
                                          return Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Text("No results found"),
                                            ),
                                          );
                                        return Container();
                                      }
                                    } else {
                                      if (resultsCounter <= docs.length)
                                        resultsCounter++;

                                      if (resultsCounter == docs.length)
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.only(top: 35),
                                            child: Text("No results found"),
                                          ),
                                        );
                                      return Container();
                                    }
                                  } else {
                                    if (resultsCounter <= docs.length)
                                      resultsCounter++;

                                    if (resultsCounter == docs.length)
                                      return Center(
                                        child: Container(
                                          padding: EdgeInsets.only(top: 35),
                                          child: Text("No results found"),
                                        ),
                                      );
                                    return Container();
                                  }
                                } else {
                                  return PackageItem(
                                    packageId: docs[index]['packageId'],
                                    organizerId: docs[index]['organizerId'],
                                    packageName: docs[index]['packageName'],
                                    imageUrl: docs[index]['images'][0],
                                    description: docs[index]['description'],
                                    price: docs[index]['price'],
                                    originalCurrency: docs[index]
                                        ['originalCurrency'],
                                    currencyConverterVal: docs[index]
                                        ['currencyConverterVal'],
                                    index: index,
                                    searchVal: searchVal,
                                    categories: docs[index]['categories'],
                                  );
                                }
                              } else {
                                if (resultsCounter <= docs.length)
                                  resultsCounter++;

                                if (resultsCounter == docs.length)
                                  return Center(
                                    child: Container(
                                      padding: EdgeInsets.only(top: 35),
                                      child: Text("No results found"),
                                    ),
                                  );
                                return Container();
                              }
                            },
                            itemCount: docs.length,
                          );
                        },
                      )
                    : Center(
                        child: Text("No packages found"),
                      ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor:
                  _currentIndex == 0 ? Colors.black : Colors.white,
              unselectedItemColor:
                  _currentIndex == 0 ? Colors.black : Colors.white,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              selectedFontSize: 16,
              unselectedFontSize: 14,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.shifting,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.format_list_numbered,
                    color: _currentIndex == 0 ? Colors.black : Colors.white,
                  ),
                  label: "All Packages",
                  backgroundColor: Theme.of(context).accentColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.recommend_outlined,
                    color: _currentIndex == 0 ? Colors.black : Colors.white,
                  ),
                  label: "Recommended",
                  backgroundColor: fc,
                ),
              ],
              onTap: (index) {
                if (_currentIndex != index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  FocusScope.of(context).unfocus();
                }
              },
            ),
            drawer: !sProviderFalse.isSearching ? MainDrawerTraveler() : null,
          );
  }
}
