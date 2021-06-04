import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travely/Screens/scanner.dart';
import 'package:travely/Service provider/package_item.dart';
import 'package:travely/Auth/auth_screen.dart';
import 'package:travely/Providers/searching_provider.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Service%20provider/add_package.dart';
import 'package:travely/Service%20provider/service_provider_profile.dart';

class SPHomePage extends StatefulWidget {
  final checker;

  const SPHomePage({this.checker = false});

  @override
  _SPHomePageState createState() => _SPHomePageState();
}

class _SPHomePageState extends State<SPHomePage> {
  bool checker = false, _isLoading = false;
  var searchController = TextEditingController();
  var snapshotDocs, searchVal = "", resultsCounter = 0;
  var sProviderFalse, sProviderTrue;
  var userId = FirebaseAuth.instance.currentUser.uid;
  int _currentIndex = 0, deleteCounter = 0;

  deleteOldPackage() async {
    deleteCounter++;
    if (checker == true) {
      await FirebaseFirestore.instance
          .collection('packages')
          .where("organizerId", isEqualTo: userId)
          .get()
          .then(
        (QuerySnapshot snapshot) {
          List<DocumentSnapshot> docs = snapshot.docs;
          for (int i = 0; i < docs.length; i++) {
            var docEndDate = docs[i]['endDate'];
            print("Doc End Date: $docEndDate");
            var endDate = docEndDate.toDate();
            print("End Date: $endDate");
            var docId = docs[i]['packageId'];
            print("Doc ID: $docId");
            if (DateTime.now().difference(endDate) > Duration(days: 1)) {
              FirebaseFirestore.instance
                  .collection("packages")
                  .doc(docId)
                  .delete();
            }
          }
        },
      );
    }
    if (deleteCounter < 2) {
      checkCollection();
    }
    setState(() {});
  }

  setRememberMe() async {
    SharedPreferences rememberMePreference =
        await SharedPreferences.getInstance();
    rememberMePreference.setBool("rememberMe", false);
  }

  clearSharedPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  getDocs() async {
    snapshotDocs = await FirebaseFirestore.instance
        .collection("packages")
        .where("organizerId", isEqualTo: userId)
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
        deleteOldPackage();
      }
    });
  }

  goToProfile(){
    Navigator.of(context).push(MaterialPageRoute(builder: (_){
      return ServiceProviderProfile();
    }));
  }

  goToAddPackage(){
    Navigator.of(context).push(MaterialPageRoute(builder: (_){
      return AddPackage();
    }));
  }

  logout(){
    setRememberMe().then((_) {
      clearSharedPrefs().then((_) {
        FirebaseAuth.instance.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => AuthScreen(),
          ),
              (route) => false,
        );
        setState(() {
          _isLoading = false;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    deleteCounter = 0;
    checkCollection();
    print("initSate");
  }

  @override
  void dispose() {
    searchController.text = "";
    searchVal = "";
    if (sProviderFalse.isSearching == true)
      sProviderTrue.setSearch(sProviderFalse.isSearching);
    super.dispose();
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
                  : Text(_currentIndex == 0
                      ? "My Travel Packages"
                      : "Package Details"),
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
                    : _currentIndex == 0
                        ? IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              sProviderTrue
                                  .setSearch(sProviderFalse.isSearching);
                            },
                          )
                        : Container(),
                sProviderFalse.isSearching == false
                    ? PopupMenuButton(
                        onSelected: (value) {
                          switch(value){
                            case 0:
                              goToProfile();
                              break;

                            case 1:
                              goToAddPackage();
                              break;

                            case 2:
                              logout();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: ListTile(
                              title: Text("My Profile"),
                              leading: Icon(Icons.person),
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: ListTile(
                              title: Text("Add Package"),
                              leading: Icon(Icons.add),
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: ListTile(
                              title: Text("Logout"),
                              leading: Icon(Icons.logout),
                            ),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
            body: _currentIndex == 1
                ? Scanner()
                : checker || widget.checker
                    ? StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('packages')
                            .where("organizerId", isEqualTo: userId)
                            .snapshots(),
                        builder: (ctx, snapShot) {
                          print("User ID from SP home page is: $userId");
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
                                  .startsWith(searchVal.toLowerCase())) {
                                print("Results Counter: $resultsCounter");
                                return PackageItem(
                                  packageId: docs[index]['packageId'],
                                  price: docs[index]['price'],
                                  packageName: docs[index]['packageName'],
                                  imageUrl: docs[index]['images'][0],
                                  originalCurrency: docs[index]
                                      ['originalCurrency'],
                                  currencyConverterVal: docs[index]
                                      ['currencyConverterVal'],
                                  index: index,
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
                        child: Text("No packages added, yet."),
                      ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              selectedItemColor:
                  _currentIndex == 0 ? Colors.black : Colors.white,
              unselectedItemColor:
                  _currentIndex == 0 ? Colors.black : Colors.white,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              selectedFontSize: 18,
              unselectedFontSize: 14,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.shifting,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.format_list_numbered,
                    color: _currentIndex == 0 ? Colors.black : Colors.white,
                  ),
                  label: "My Packages",
                  backgroundColor: Theme.of(context).accentColor,
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.qr_code_scanner,
                    color: _currentIndex == 0 ? Colors.black : Colors.white,
                  ),
                  label: "Scan",
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
          );
  }
}
