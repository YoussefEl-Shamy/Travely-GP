import 'package:flutter/material.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/auth/auth_form.dart';
import 'package:travely/auth/auth_screen.dart';

Color thc = Color(0xFF007965);

class WaitingList extends StatelessWidget {
  var textStyle = TextStyle(color: Colors.white, fontSize: 25);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: thc,
      body: Container(
        margin: EdgeInsets.all(15),
        color: thc,
        /*decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 5)
        ),*/
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Thanks for joining us",
                style: textStyle,
              ),
              SizedBox(height: 30),
              Loading(),
              SizedBox(height: 30),
              Text(
                "We will notify you when your account is confirmed",
                style: textStyle,
              ),
              SizedBox(height: 50),
              FlatButton(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      "Go to login form",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Theme.of(context).accentColor,
                splashColor: Colors.red,
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (_) {
                    return AuthScreen();
                  }));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
