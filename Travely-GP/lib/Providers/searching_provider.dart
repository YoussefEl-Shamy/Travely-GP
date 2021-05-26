import 'package:flutter/cupertino.dart';

class SearchingProvider with ChangeNotifier{
  bool isSearching = false;

  setSearch(bool isSearching){
    this.isSearching = !isSearching;
    print("isSearching: ${this.isSearching}");
    notifyListeners();
  }
}