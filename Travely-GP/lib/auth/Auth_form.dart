import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(String email,String password,String username,bool islogin,BuildContext ctx) submitfn;
  final bool isloading;
  AuthForm(this.submitfn, this.isloading);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formkey = GlobalKey<FormState>();
  bool _islogin = true;
  String _email = "";
  String _password = "";
  String _username = "";

  void _sumbit() {
    final isvalid = _formkey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isvalid) {
      _formkey.currentState.save();
      widget.submitfn(
          _email.trim(), _password.trim(), _username.trim(), _islogin,context
      );
      print(_email);
      print(_password);
      print(_username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  key: ValueKey('email'),
                  validator: (val) {
                    if (val.isEmpty || !val.contains('@')) {
                      return "please enter a Valid Email Addres";
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
                if(widget.isloading)
                  CircularProgressIndicator(),
                if(!widget.isloading)
                RaisedButton(
                    child: Text(_islogin ? 'Login' : 'Sign up'),
                    onPressed: _sumbit),
                    if(!widget.isloading)
                FlatButton(
                  textColor: Theme.of(context).primaryColor,
                  child: Text(_islogin
                      ? 'Create new Account '
                      : 'I already have Account'),
                  onPressed: null,

                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
