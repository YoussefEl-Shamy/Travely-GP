import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  final String errorText;
  final bool isVisible;

  ErrorText({
    @required this.errorText,
    @required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Text(
        errorText,
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
