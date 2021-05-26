import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/admin_email_pass_provider.dart';
import 'package:travely/Registration%20form/registration_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthForm extends StatefulWidget {
  final Function(String email, String password, String username, bool islogin,
      BuildContext ctx) submitFn;
  final bool isLoading;

  AuthForm(this.submitFn, this.isLoading);

  @override
  _AuthFormState createState() => _AuthFormState();
}

Color thc = Color(0xFF007965);

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true, _rememberMe = false;
  String _userId = "";
  String _email = "";
  String _password = "";
  String _username = "";

  void _submit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget
          .submitFn(
        _email.trim(),
        _password.trim(),
        _username.trim(),
        _isLogin,
        context,
      )
          .then((_) {
        _userId = FirebaseAuth.instance.currentUser.uid;
        print("Finally user ID is: $_userId");
        sharedPreferencesFn().then((_) {
          getRememberMe().then((_) {
            print("Remember Me value from SHP is: $rememberMe");
          });
          getUserId().then((_) {
            print("User ID from SHP is: $userId");
          });
        });
        print("LOL inside then");
      });
      print("LOL outside then");
      print(_email);
      print(_password);
      print(_username);

      Provider.of<IdEmailPassProvider>(context, listen: false)
          .setEmailPass(_email, _password);
    }
  }

  sharedPreferencesFn() async {
    SharedPreferences rememberMePreference =
        await SharedPreferences.getInstance();
    rememberMePreference.setBool("rememberMe", _rememberMe);

    SharedPreferences userIdPreference = await SharedPreferences.getInstance();
    userIdPreference.setString("userId", _userId);
  }

  bool rememberMe;

  getRememberMe() async {
    SharedPreferences rememberMePreference =
        await SharedPreferences.getInstance();
    rememberMe = rememberMePreference.getBool("rememberMe");
  }

  String userId;

  getUserId() async {
    SharedPreferences userIdPreference = await SharedPreferences.getInstance();
    userId = userIdPreference.getString("userId");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                    bottom: BorderSide(color: thc, width: 2.5),
                  )),
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: thc,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextFormField(
                  key: ValueKey('email'),
                  validator: (val) {
                    if (val.isEmpty || !val.contains('@')) {
                      return "please enter a Valid Email Address";
                    }
                    return null;
                  },
                  onSaved: (val) => _email = val,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Email Address"),
                ),
                TextFormField(
                  key: ValueKey('Password'),
                  validator: (val) {
                    if (val.isEmpty || val.length < 7) {
                      return "Password must be at least 7 Characters";
                    }
                    return null;
                  },
                  onSaved: (val) => _password = val,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
                SizedBox(
                  height: 12,
                ),
                if (!widget.isLoading)
                  CheckboxListTile(
                    title: Text(
                      "Remember Me!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _rememberMe,
                    onChanged: (bool checked) {
                      setState(() {
                        _rememberMe = checked;
                        print("Remember Me value is: $_rememberMe");
                      });
                    },
                    activeColor: Theme.of(context).primaryColor,
                    checkColor: Colors.white,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                if (widget.isLoading) CircularProgressIndicator(),
                SizedBox(
                  height: 15,
                ),
                if (!widget.isLoading)
                  FlatButton(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          "Login",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Theme.of(context).accentColor,
                    splashColor: Colors.red,
                    onPressed: () {
                      _submit();
                    },
                  ),
                if (!widget.isLoading)
                  FlatButton(
                    textColor: Colors.black,
                    child: Text(_isLogin
                        ? 'Create new Account '
                        : 'I already have Account'),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) {
                            return RegistrationForm();
                          },
                        ),
                      );
                    },
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
