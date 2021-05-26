import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {
  String _token;
  String _userID;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null) {
      return _token;
    }
    return null;
  }

  authentication(
      String email,
      String password,
      String urlSegment,
      String username,
      String address,
      String phone,
      String role,
      String imageUrl,
      {DateTime dateOfBirth,
      String gender,
      String serviceProvider}) async {
    final String url =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyChe1hbKXn2Yzo0j86-veVZ0UNQsF8PXr0";

    try {
      if (role == "Traveler") {
        final res = await http.post(Uri.parse(url),
            body: json.encode({
              'email': email,
              'password': password,
              'returnSecureToken': true,
            }));
        final resData = json.decode(res.body);
        print(resData);
        if (resData['error'] != null) {
          throw "${resData['error']['message']}";
        }

        _token = resData['idToken'];
        _userID = resData['localId'];
        notifyListeners();
        print("User ID is: $_userID");
        print("We got that place");
        await FirebaseFirestore.instance
            .collection("travelers")
            .doc(_userID)
            .set({
          "ID": _userID,
          "username": username,
          "email": email,
          "password": password,
          "address": address,
          "phone": phone,
          "role": role,
          "dateOfBirth": dateOfBirth,
          "gender": gender,
          "imageUrl": imageUrl,
        });
        print("We did it");
      } else if (role == "Service Provider") {
        var id = FirebaseFirestore.instance
            .collection("service providers requests")
            .doc()
            .id
            .toString();
        print("The needed ID is here: $id");
        await FirebaseFirestore.instance
            .collection("service providers requests")
            .doc(id)
            .set({
          "ID": id,
          "username": username,
          "email": email,
          "password": password,
          "address": address,
          "phone": phone,
          "role": role,
          "serviceProvider": serviceProvider,
          "imageUrl": imageUrl,
        });
      }
    } catch (e) {
      throw e;
    }
  }
}
