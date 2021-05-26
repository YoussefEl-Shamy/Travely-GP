import 'package:flutter/material.dart';

class ShowDetails with ChangeNotifier{
  var cPAD = false;
  var cTAD = false;

  provider(){
    cPAD=true;
    cTAD=false;
    notifyListeners();
  }

  traveler(){
    cPAD=false;
    cTAD=true;
    notifyListeners();
  }
}