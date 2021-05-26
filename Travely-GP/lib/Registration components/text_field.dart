import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller, labelText, hintText, icon, inputType;
  var inputMaxLength, initVal;

  MyTextField(
    this.controller,
    this.labelText,
    this.hintText,
    this.icon,
    this.inputType, {
    this.inputMaxLength,
    this.initVal,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller..text = initVal,
      maxLength: inputMaxLength,
      decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: icon,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(60),
              borderSide: BorderSide(color: Colors.redAccent))),
      keyboardType: inputType,
    );
  }
}
