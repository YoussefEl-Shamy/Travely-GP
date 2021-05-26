import 'package:flutter/cupertino.dart';

class EmailExistence with ChangeNotifier{
  bool emailExist;
  String id;

  setExistence({bool result, String id}){
    emailExist = result;
    this.id = id;
    notifyListeners();
  }
}