import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Color thc = Color(0xFF007965);
class LoadingWave extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitWave(
        color: thc,
        size: 30.0,
      ),
    );
  }
}
