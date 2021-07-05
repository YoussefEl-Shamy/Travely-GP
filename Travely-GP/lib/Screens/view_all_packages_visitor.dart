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

class ViewPackagesVisitor extends StatefulWidget {
  @override
  ViewPackagesVisitorState createState() => ViewPackagesVisitorState();
}

class ViewPackagesVisitorState extends State<ViewPackagesVisitor> {
  var searchController = TextEditingController();
  Color fc = Color(0xFFf58634);
  bool checker = false;
  var snapshotDocs, searchVal = "", resultsCounter = 0;
  var sProviderFalse, sProviderTrue;
  String imageUrl = "";
  var unRatedNum, _isLoading = false;
  var packagesIDs = [];
  var finishedPackagesIDs = [];

  getPackagesIDs() async {
    await FirebaseFirestore.instance.collection('travelersPackages').get().then(
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

  @override
  void initState() {
    super.initState();
    checkCollection();
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
                  : Text("Travel Packages"),
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
              ],
            ),
            body: checker
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('packages')
                        .orderBy("startDate", descending: true)
                        .snapshots(),
                    builder: (ctx, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
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
                              originalCurrency: docs[index]['originalCurrency'],
                              currencyConverterVal: docs[index]
                                  ['currencyConverterVal'],
                              index: index,
                              searchVal: searchVal,
                              categories: docs[index]['categories'],
                              actor: "visitor",
                            );
                          } else {
                            if (resultsCounter <= docs.length) resultsCounter++;

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
          );
  }
}
