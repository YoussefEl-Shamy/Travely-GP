import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travely/Screens/loading.dart';
import 'package:travely/Traveler/recommended_package_item.dart';

class RecommendedTravels extends StatefulWidget {
  @override
  _RecommendedTravelsState createState() => _RecommendedTravelsState();
}

class _RecommendedTravelsState extends State<RecommendedTravels> {
  var userId = FirebaseAuth.instance.currentUser.uid;
  var ratedPackagesIds = [];
  Map packageCs = {};
  var results = [];
  bool _isLoading = true, checker = false;
  var snapshotDocs, packageRank = 0;

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

  Future<void> loadPackages() async {
    String uri =
        "https://us-central1-travely-78048.cloudfunctions.net/yarab?travelerId=$userId";
    var response = await http.get(Uri.parse(Uri.encodeFull(uri)),
        headers: {"Accept": "application/json"});
    var responseBody =
        await json.decode(response.body) as Map<dynamic, dynamic>;
    print("$responseBody");
    responseBody.forEach((key, value) {
      ratedPackagesIds.add(key);
      packageCs.addAll(value);
      print(packageCs);

      setRate();
      print("Zzzzzzzzzzzzzzzzzz 1");
      setState(() {
        _isLoading = false;
      });
    });
  }

  var totalScoresMap = {};

  Future<void> setRate() async {
    packageCs.forEach((key, value) async {
      await FirebaseFirestore.instance
          .collection('packages')
          .doc(key)
          .get()
          .then((value1) async {
        var data1 = value1.data();
        var organizerId = data1['organizerId'];
        await FirebaseFirestore.instance
            .collection('service providers')
            .doc(organizerId)
            .get()
            .then((value2) {
          var data2 = value2.data();
          var rate = data2['rate'];
          var totalScore = rate + (value * 5);
          print("Total Score: $totalScore for package: $key");
          print("\n\n%%%%%%%%%%%%%%%%%%%%%%%%%%%\n");
          if (!totalScoresMap.containsKey(key)) {
            totalScoresMap[key] = totalScore;
            print("Total scores map: $totalScoresMap");
          } else {
            totalScoresMap[key] = totalScoresMap[key] + totalScore;
            print(totalScoresMap.keys.toList());
            print(totalScoresMap.values.toList());
            print("Total scores map: $totalScoresMap");
            setState(() {
              _isLoading = false;
            });
          }
        });
      });
    });
  }

  var sortedKeysList = [];
  var sortedValuesList = [];

  sortMap() {
    print("The beginning of shit 2");
    print("my map: $totalScoresMap");
    sortedKeysList = totalScoresMap.keys.toList();
    sortedValuesList = totalScoresMap.values.toList();
    print("My lists at the beginning: $sortedKeysList \n$sortedValuesList");
    for (int i = 0; i < sortedValuesList.length - 1; i++) {
      for (int j = i + 1; j < sortedValuesList.length; j++) {
        if (sortedValuesList[i] < sortedValuesList[j]) {
          setState(() {
            var tempValue = sortedValuesList[i];
            sortedValuesList[i] = sortedValuesList[j];
            sortedValuesList[j] = tempValue;

            var tempKey = sortedKeysList[i];
            sortedKeysList[i] = sortedKeysList[j];
            sortedKeysList[j] = tempKey;
          });
        }
      }
    }

    print("My Final Sorted Lists which I fuckin' admire");
    print("$sortedKeysList\n$sortedValuesList\n");

    return Container();
  }

  getPackages(String id) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection("packages").doc(id).snapshots(),
      builder: (ctx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        var data = snapShot.data;
        return RecommendedPackageItem(
          packageId: data['packageId'],
          organizerId: data['organizerId'],
          packageName: data['packageName'],
          imageUrl: data['images'][0],
          description: data['description'],
          price: data['price'],
          originalCurrency: data['originalCurrency'],
          currencyConverterVal: data['currencyConverterVal'],
          index: packageRank++,
          categories: data['categories'],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    checkCollection();
    loadPackages().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: checker
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        sortMap(),
                        for (var id in sortedKeysList) getPackages(id),
                      ],
                    ),
                  )
                : Center(
                    child: Text(
                      "Sorry, There is no recommendations for you till now.",
                    ),
                  ),
          );
  }
}
