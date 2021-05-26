import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travely/Admin/admin_home_page.dart';
import 'package:travely/Providers/admin_email_pass_provider.dart';
import 'package:travely/Providers/email_existance_checker_provider.dart';
import 'package:travely/Providers/searching_provider.dart';
import 'package:travely/Providers/un_rated_provider.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Service%20provider/service_provider_home_page.dart';
import 'Providers/auth_provider.dart';
import 'Providers/registration_parameters.dart';
import 'Providers/traveler_providerServices_details_provider.dart';
import 'package:travely/auth/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'Traveler/traveler_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<Auth>(create: (_) => Auth()),
      ChangeNotifierProvider<ShowDetails>(create: (_) => ShowDetails()),
      ChangeNotifierProvider<RegParam>(create: (_) => RegParam()),
      ChangeNotifierProvider<IdEmailPassProvider>(create: (_) => IdEmailPassProvider()),
      ChangeNotifierProvider<SearchingProvider>(create: (_) => SearchingProvider()),
      ChangeNotifierProvider<EmailExistence>(create: (_) => EmailExistence()),
      ChangeNotifierProvider<UnRatedProvider>(create: (_) => UnRatedProvider()),
    ],
    child: MyApp(),
  ));
}

Color pc = Color(0xFF00af91);
Color ac = Color(0xFFffcc29);
Color thc = Color(0xFF007965);
Color fc = Color(0xFFf58634);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: pc,
        accentColor: ac,
        canvasColor: Color.fromRGBO(255, 254, 229, 1),
        fontFamily: 'Raleway',
        accentColorBrightness: Brightness.dark,
      ),
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  bool rememberMe, _isLoading = true;
  SharedPreferences rememberMePreference;

  getRememberMe() async {
    rememberMePreference = await SharedPreferences.getInstance();
    if (rememberMePreference.containsKey("rememberMe")) {
      setState(() {
        rememberMe = rememberMePreference.getBool("rememberMe");
      });
    } else {
      setState(() {
        rememberMe = false;
      });
    }

    print("rememberMe is : $rememberMe");
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  @override
  void initState() {
    _messaging.getToken().then((token){
      print(token);
    });
    print("initState");
    super.initState();
    getRememberMe().then((_) {
      getUserId().then((_){
        setRole(userId).then((_){
          setState(() {
            _isLoading = false;
          });
          print("Loading is completed");
        });
      });
    });
  }

  String userId;

  getUserId() async {
    SharedPreferences userIdPreference = await SharedPreferences.getInstance();
    if (userIdPreference.containsKey("userId")) {
      print(":inside if statement");
      setState(() {
        userId = userIdPreference.getString("userId");
      });
    } else {
      print("inside else");
      setState(() {
        userId = "";
      });
    }

    print("User ID from getUserId in main file is : $userId");
  }

  String _role = "";
  checkExistInAdmin(String userId) async {
    try {
      await FirebaseFirestore.instance.doc("admin/$userId").get().then((doc) {
        if (doc.exists){
          setState(() {
            _role = "admin";
          });
          print("TheAdmin is here");
        }
      });
    } catch (e) {
      print(e);
    }
  }

  checkExistInSP(String userId) async {
    try {
      await FirebaseFirestore.instance.doc("service providers/$userId").get().then((doc) {
        if (doc.exists){
          setState(() {
            _role = "service provider";
          });
          print("TheProvider is here");
        }
      });
    } catch (e) {
      print(e);
    }
  }

  checkExistInTravelers(String userId) async {
    try {
      await FirebaseFirestore.instance.doc("travelers/$userId").get().then((doc) {
        if (doc.exists)
          setState(() {
            _role = "traveler";
          });
      });
    } catch (e) {
      print(e);
    }
  }

  setRole(String userId) async{
    await checkExistInAdmin(userId);
    await checkExistInSP(userId);
    await checkExistInTravelers(userId);
  }

  @override
  Widget build(BuildContext context) {
    print("Do we get here first or there?");
    return _isLoading
        ? Loading()
        : Scaffold(
            body: Container(
              child: rememberMe? StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (ctx, snapShot){

                  print("Remember me: $rememberMe");
                  print("3-Try to get the user id here: $userId");
                  print("User role: $_role");
                  if(_role == "admin"){
                    return AdminHomePage();
                  } else if(_role == "service provider"){
                    return SPHomePage();
                  } else return FirstPage();
                },
              ): AuthScreen(),
            ),
          );
  }
}
