import 'package:flutter/cupertino.dart';

class RegParam with ChangeNotifier{
  String dialCode = "+20", phoneNumber = "", gender = "Male", serviceProvider = "Travels organizer";
  DateTime dateOfBirth;
  int travelerOrProvider;

  getDialCode(String dialCode){
    this.dialCode = dialCode;
    notifyListeners();
  }

  getPhoneNumber(String phoneNumber){
    this.phoneNumber = phoneNumber;
    notifyListeners();
  }

  getGender(String gender){
    this.gender = gender;
    notifyListeners();
  }

  getServiceProvider(String serviceProvider){
    this.serviceProvider = serviceProvider;
    notifyListeners();
  }

  getDateOfBirth(DateTime dateOfBirth){
    this.dateOfBirth = dateOfBirth;
    notifyListeners();
  }

  getTravelerOrProvider(int travelerOrProvider){
    this.travelerOrProvider = travelerOrProvider;
    notifyListeners();
  }
}