import 'package:flutter/material.dart';

class UnRatedProvider with ChangeNotifier{
  var unRatedNum;

  setUnRatedNum(unRatedNum){
    this.unRatedNum = unRatedNum;
    notifyListeners();
  }
}
