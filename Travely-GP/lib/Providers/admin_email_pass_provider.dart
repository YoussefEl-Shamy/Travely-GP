import 'package:flutter/cupertino.dart';

class IdEmailPassProvider with ChangeNotifier{
  String email, password, id;

  setEmailPass(String email, String password){
    this.email = email;
    this.password = password;
    notifyListeners();
  }

  setAdminId(id){
    this.id = id;
  }
}