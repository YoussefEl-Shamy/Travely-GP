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

  getPackagesIDs() async {
    print("The beginning of shit");
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

  deleteTravelerTicket() {
    getPackagesIDs().then((_){
      print("package IDs length: ${packagesIDs.length}");
      for (int i = 0; i < packagesIDs.length; i++) {
        checkDoc(packagesIDs[i]).then((_){
          print("checker 1: $checkDocExistence");
          print("checker 2: $checker");
          print("package number ${i+1}: ${packagesIDs[i]}");
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
    Provider.of<UnRatedProvider>(context).setUnRatedNum(unRatedNum);
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

  getTravelerImage() {
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
              child: CircularProgressIndicator(),
            );

          var data = snapShot.data;
          imageUrl = data['imageUrl'];
          return InkWell(
            borderRadius: BorderRadius.circular(300),
            child: CircleAvatar(
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey,
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return TravelerProfile();
              }));
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sProviderFalse = Provider.of<SearchingProvider>(context, listen: false);
    sProviderTrue = Provider.of<SearchingProvider>(context, listen: true);
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: sProviderFalse.isSearching
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
                          borderSide: BorderSide(color: Colors.white, width: 3),
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        hintText: ("Search for package"),
                        hintStyle: TextStyle(color: Colors.white60),
                      ),
                    )
                  : _currentIndex == 0
                      ? Text("Travel Packages")
                      : Text("Recommended Packages"),
              actions: <Widget>[
                sProviderFalse.isSearching
                    ? IconButton(
                        icon: Icon(Icons.cancel),
                        onPressed: () {
                          searchController.text = "";
                          searchVal = "";
                          sProviderTrue.setSearch(sProviderFalse.isSearching);
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          sProviderTrue.setSearch(sProviderFalse.isSearching);
                        },
                      ),
                sProviderFalse.isSearching ? Container() : getTravelerImage(),
              ],
            ),
            body: _currentIndex == 1
                ? RecommendedTarvels()
                : checker
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('packages')
                            .orderBy("packageName")
                            .snapshots(),
                        builder: (ctx, snapShot) {
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
