import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final bool signUp;

  Header({this.signUp});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.92,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        child: Container(
          color: Color(0xFFf58634),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Welcome to ",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Travely",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  Expanded(child: Container()),
                  signUp
                      ? FlatButton(
                          child: Text("SignIn", style: TextStyle(color: Colors.white),),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      : Container(),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Expand your horizon",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
