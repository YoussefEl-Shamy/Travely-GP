import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final controller;
  PasswordField(this.controller);

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
          labelText: "Password",
          hintText: "Enter your password",
          prefixIcon: Icon(Icons.vpn_key_rounded),
          suffixIcon: IconButton(
            icon: Icon(
              isPasswordVisible? Icons.visibility : Icons.visibility_off
            ),
            onPressed: (){
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(60),
              borderSide: BorderSide(color: Colors.redAccent))),
      keyboardType: TextInputType.visiblePassword,
      obscureText: isPasswordVisible,
    );
  }
}

