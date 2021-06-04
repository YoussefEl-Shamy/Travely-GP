import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travely/Admin/users_list.dart';
import 'package:travely/Admin/view_packages.dart';
import 'package:travely/Providers/admin_email_pass_provider.dart';
import 'package:travely/Providers/un_rated_provider.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Traveler/rated_travels.dart';
import 'package:travely/Traveler/un_rated_travels.dart';
import 'package:travely/Traveler/view_my_tickets.dart';
import 'package:travely/auth/auth_screen.dart';

class MainDrawerTraveler extends StatefulWidget {
  @override
  _MainDrawerTravelerState createState() => _MainDrawerTravelerState();
}

class _MainDrawerTravelerState extends State<MainDrawerTraveler> {
  bool _isLoading = false;
  var userId = FirebaseAuth.instance.currentUser.uid;
  var unRatedNum;
  Stream unRatedNumStream;

  setRememberMe() async {
    SharedPreferences rememberMePreference =
        await SharedPreferences.getInstance();
    rememberMePreference.setBool("rememberMe", false);
  }

  clearSharedPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  updateSeen() {
    FirebaseFirestore.instance
        .collection("travelers")
        .doc(userId)
        .update({"unRatedNum": 0});
  }

  getUnRatedNumStream() {
    return Container(
      height: 32,
      width: 32,
      child: StreamBuilder(
          stream: unRatedNumStream,
          builder: (ctx, snapShot) {
            if (snapShot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());

            var data = snapShot.data;
            var unRatedNum = data['unRatedNum'];
            return unRatedNum < 10 && unRatedNum > 0
                ? Container(
                    height: 30,
                    width: 30,
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                    child: Center(
                        child: Text(
                      "$unRatedNum",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )),
                  )
                : unRatedNum == 0
                    ? Container(
                        height: 1,
                        width: 1,
                      )
                    : Container(
                        height: 32,
                        width: 32,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        child: Center(
                            child: Text(
                          "+9",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        )),
                      );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    unRatedNumStream = FirebaseFirestore.instance
        .collection("travelers")
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    unRatedNum = Provider.of<UnRatedProvider>(context, listen: true).unRatedNum;
    return _isLoading
        ? Loading()
        : Drawer(
            child: Column(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: 40,
                    left: 25,
                    bottom: 20,
                    right: 20,
                  ),
                  alignment: Alignment.centerLeft,
                  color: Theme.of(context).primaryColor,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Traveler ",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 55,
                              ),
                            ],
                          ),
                          Text(
                            "Dashboard ",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.airplane_ticket_outlined, size: 26),
                  title: Text(
                    "My Tickets",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return ViewTickets();
                    }));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star_rate_outlined, size: 26),
                  title: Text(
                    "Un Rated Travels",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  trailing: getUnRatedNumStream(),
                  onTap: () {
                    updateSeen();
                    Provider.of<UnRatedProvider>(context, listen: false)
                        .setUnRatedNum(0);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return UnRatedTravels();
                    }));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star_rate_rounded, size: 26),
                  title: Text(
                    "Rated Travels",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return RatedTravels();
                    }));
                  },
                ),
                Expanded(child: Container()),
                Divider(
                  height: 5,
                  color: Colors.black,
                ),
                ListTile(
                  leading: Icon(Icons.logout, size: 26),
                  title: Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isLoading = true;
                    });
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
                  },
                ),
              ],
            ),
          );
  }
}
