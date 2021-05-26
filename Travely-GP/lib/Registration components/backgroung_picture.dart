import 'package:flutter/material.dart';

class BackgroundPicture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF007965),
                      Colors.white,
                    ]
                )
            ),
            height: 400,
          ),
      Opacity(
        opacity: 0.55,
        child: Image.asset(
          "assets/images/background.jpg",
          height: 400,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    ]);
  }
}
