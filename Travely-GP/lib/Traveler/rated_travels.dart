import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/searching_provider.dart';
import 'package:travely/Traveler/rated_travel_items.dart';

class RatedTravels extends StatefulWidget {
  @override
  _RatedTravelsState createState() => _RatedTravelsState();
}

class _RatedTravelsState extends State<RatedTravels> {
  var userId = FirebaseAuth.instance.currentUser.uid;
  var searchVal = "", resultsCounter = 0;
  var sProviderFalse, sProviderTrue;
  TextEditingController searchController = TextEditingController();

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
            : Text("Rated Packages"),
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("ratedTravels")
            .where("travelerId", isEqualTo: userId)
            .snapshots(),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          var docs = snapShot.data.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, index) {
              if (docs[index]['packageName']
                  .toString()
                  .toLowerCase()
                  .contains(searchVal.toLowerCase())) {
                print("Results Counter: $resultsCounter");
                print("Package Name: $searchVal");
                return RatedTravelsItem(
                  index: index,
                  searchVal: searchVal,
                  packageName: docs[index]['packageName'],
                  ticketId: docs[index]["ticketId"],
                  packageId: docs[index]['packageId'],
                  organizerId: docs[index]['organizerId'],
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
          );
        },
      ),
    );
  }
}
