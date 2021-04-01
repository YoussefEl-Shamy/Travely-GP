import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Firstpage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
      title: Text("first page"),
      ),
      body: Center(

        child: Column(

    mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'You have pushed the button this many times:',
        ),
        Text(
          'GO',
          style: Theme.of(context).textTheme.headline4,
        ),
      ],
    ),
    ),
    floatingActionButton: FloatingActionButton(
    onPressed: ()=>
    FirebaseAuth.instance.signOut(),
    tooltip: 'Increment',
    child: Icon(Icons.exit_to_app),
    ),
    );
  }
}
