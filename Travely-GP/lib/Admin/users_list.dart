import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Admin/user_unit.dart';
import 'package:travely/Providers/searching_provider.dart';
import 'package:travely/Screens/loading.dart';

// ignore: must_be_immutable
class UsersList extends StatefulWidget {
  final String role;

  const UsersList(this.role);

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  var listController = ScrollController();
  bool _isLoading = false, checker = false;
  var snapshotDocs, searchVal = "", resultsCounter = 0;
  var searchController = TextEditingController();
  var sProviderFalse, sProviderTrue;

  getDocs() async {
    snapshotDocs =
        await FirebaseFirestore.instance.collection(widget.role).get();
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
    setState(() {
      _isLoading = false;
    });
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
                        hintText: ("Search for ${widget.role}"),
                        hintStyle: TextStyle(color: Colors.white60),
                      ),
                    )
                  : widget.role == "travelers"
                      ? Text("Travelers")
                      : Text("Service Providers"),
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
                        .collection(widget.role)
                        .snapshots(),
                    builder: (ctx, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return Loading();
                      }
                      final docs = snapShot.data.docs;
                      return ListView.builder(
                        itemBuilder: (ctx, index) {
                          if (docs[index]['username']
                              .toString().toLowerCase()
                              .contains(searchVal.toLowerCase()) || docs[index]['email']
                              .toString().toLowerCase()
                              .contains(searchVal.toLowerCase())) {
                            return UserUnit(
                              role: widget.role,
                              userId: docs[index]["ID"],
                              imageUrl: docs[index]["imageUrl"],
                              username: docs[index]["username"],
                              email: docs[index]["email"],
                              searchVal: searchVal,
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
                    child: Text("No ${widget.role} found"),
                  ),
          );
  }
}
