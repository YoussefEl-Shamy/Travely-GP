import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travely/Admin/users_list.dart';
import 'package:travely/Admin/view_packages.dart';
import 'package:travely/Providers/admin_email_pass_provider.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/auth/auth_screen.dart';

class MainDrawerAdmin extends StatefulWidget {
  @override
  _MainDrawerAdminState createState() => _MainDrawerAdminState();
}

class _MainDrawerAdminState extends State<MainDrawerAdmin> {
  bool _isLoading = false;

  updateAdminToken(BuildContext context) async {
    var admins = FirebaseFirestore.instance.collection("admin");
    var adminId = Provider.of<IdEmailPassProvider>(context, listen: false).id;
    return admins
        .doc(adminId)
        .update({'devToken': '0'})
        .then((value) {})
        .catchError((e) => print("Cannot be updated: $e"));
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

  @override
  Widget build(BuildContext context) {
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
                                "Admin ",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                              Icon(
                                Icons.manage_accounts,
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
                SizedBox(
                  height: 25,
                ),
                ListTile(
                  leading: Icon(Icons.supervised_user_circle, size: 26),
                  title: Text(
                    "View Travelers",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) {
                          return UsersList("travelers");
                        },
                      ),
                    );
                  },
                ),
                Divider(
                  height: 5,
                  color: Colors.black,
                ),
                ListTile(
                  leading: Icon(Icons.supervisor_account, size: 26),
                  title: Text(
                    "View Service Provider",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return UsersList("service providers");
                    }));
                  },
                ),
                Divider(
                  height: 5,
                  color: Colors.black,
                ),
                ListTile(
                  leading: Icon(Icons.travel_explore, size: 26),
                  title: Text(
                    "View Travels Packages",
                    style: TextStyle(
                      fontSize: 22,
                      fontFamily: 'RobotoCondensed',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return ViewPackages();
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
                    updateAdminToken(context).then((_) {
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
                    });
                  },
                ),
              ],
            ),
          );
  }
}
