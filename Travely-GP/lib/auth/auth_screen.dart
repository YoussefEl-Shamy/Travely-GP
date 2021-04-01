import 'package:firebase_auth/firebase_auth.dart';
import 'package:loggg/auth/Auth_form.dart';
import 'package:flutter/material.dart';
class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isloading =false;
  String message ="error Occurred";
  void _submitAuthForm(String email,String password,String username,bool islogin,BuildContext ctx) async{
    UserCredential authResult;
    try {
      setState(() {
        _isloading =true;
      });
      if(islogin==true){
        authResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password
        );

      }else{
        authResult = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password
        );
      }

    }
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        message='The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message='The account already exists for that email.';
      } else if (e.code == 'user-not-found') {
        message='No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message='Wrong password provided for that user.';
      }
      Scaffold.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      setState(() {
        _isloading =false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isloading =false;
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm,_isloading),
    );
  }
}
