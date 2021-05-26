import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Color thc = Color(0xFF007965);
Color fc = Color(0xFFf58634);
class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: thc,
      child: Center(
        child: SpinKitChasingDots(
          color: fc,
          size: 80.0,
        ),
      ),
    );
  }
}
