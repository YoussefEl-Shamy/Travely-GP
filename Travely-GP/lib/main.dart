import 'package:firebase_auth/firebase_auth.dart';
import 'package:loggg/Firstpage.dart';
import 'package:loggg/auth/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async  {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

          primarySwatch: Colors.lightBlue,
          backgroundColor: Colors.amberAccent,
          accentColor: Colors.deepPurple,
          accentColorBrightness: Brightness.dark,
          buttonTheme: ButtonTheme.of(context).copyWith(
              buttonColor: Colors.lightBlue,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusDirectional.circular(20),
              )
          )
      ),
      home: StreamBuilder(stream:FirebaseAuth.instance.authStateChanges(),
        builder: (ctx,snapShot){
        if(snapShot.hasData){
        return  Firstpage();
        }else{
          return AuthScreen();
        }
        },
      ),
    );
  }
}