import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:travely/Admin/package_item.dart';
import 'package:travely/Providers/searching_provider.dart';

class ViewPackages extends StatefulWidget {
  @override
  _ViewPackagesState createState() => _ViewPackagesState();
}

class _ViewPackagesState extends State<ViewPackages> {
  var searchController = TextEditingController();
  bool checker = false;
  var snapshotDocs, searchVal = "", resultsCounter = 0;
  var sProviderFalse, sProviderTrue;

  getDocs() async {
    snapshotDocs = await FirebaseFirestore.instance.collection("packages").get();
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

  @override
  Widget build(BuildContext context) {
    sProviderFalse = Provider.of<SearchingProvider>(context, listen: false);
    sProviderTrue = Provider.of<SearchingProvider>(context, listen: true);
    return Scaffold(
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
              stream:
                  FirebaseFirestore.instance.collection('packages').orderBy("packageName").snapshots(),
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
                        index: index,
                        searchVal:searchVal,
                        description: docs[index]['description'],
                        price: docs[index]['price'],
                        currencyConverterVal: docs[index]['currencyConverterVal'],
                        originalCurrency: docs[index]['originalCurrency'],
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
