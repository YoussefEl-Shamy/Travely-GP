import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travely/Registration%20components/text_field.dart';

class EditTravelerProfile extends StatefulWidget {
  final username, email, phone, address, birthDate, gender;

  const EditTravelerProfile(
      {this.username,
      this.email,
      this.phone,
      this.address,
      this.birthDate,
      this.gender});

  @override
  _EditTravelerProfileState createState() => _EditTravelerProfileState();
}

class _EditTravelerProfileState extends State<EditTravelerProfile> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  var birthDate, username, phone, address;

  String initVal;
  List<String> genders = ["Male", "Female"];

  updateTravelerData() {
    var traveler = FirebaseFirestore.instance
        .collection("travelers")
        .doc(FirebaseAuth.instance.currentUser.uid);
    Navigator.of(context).pop();
    return traveler
        .update({
          'username': usernameController.text,
          'address': addressController.text,
          'phone': phoneController.text,
          'dateOfBirth': birthDate,
          'gender': initVal,
        })
        .then((value) {})
        .catchError((e) => print("Cannot be updated: $e"));
  }

  void birthDatePicker() {
    showDatePicker(
      context: context,
      initialDate: birthDate,
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) {
        return 0;
      }
      setState(() {
        birthDate = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    birthDate = widget.birthDate;
    phone = widget.phone;
    address = widget.address;
    username = widget.username;
    initVal = widget.gender;
  }

  @override
  Widget build(BuildContext context) {
    print("username controller: ${usernameController.text}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile Data"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 20.0, right: 10, left: 10),
          child: Column(
            children: [
              TextField(
                controller: usernameController..text = username,
                maxLength: 30,
                decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter new username",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.redAccent))),
                keyboardType: TextInputType.text,
                onChanged: (newValue) {
                  username = newValue;
                },
              ),
              SizedBox(height: 15),
              TextField(
                controller: phoneController..text = phone,
                decoration: InputDecoration(
                    labelText: "Phone",
                    hintText: "Enter new phone number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.redAccent))),
                keyboardType: TextInputType.text,
                onChanged: (newValue) {
                  phone = newValue;
                },
              ),
              SizedBox(height: 15),
              TextField(
                controller: addressController..text = address,
                decoration: InputDecoration(
                    labelText: "Address",
                    hintText: "Enter new address",
                    prefixIcon: Icon(Icons.home),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.redAccent))),
                keyboardType: TextInputType.text,
                onChanged: (newValue) {
                  address = newValue;
                },
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: RaisedButton(
                      padding: EdgeInsets.all(15),
                      color: Color(0xFF007965),
                      textColor: Colors.white,
                      child: Text("${DateFormat.yMMMd().format(birthDate)}"),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        birthDatePicker();
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: initVal,
                          icon: Icon(
                            Icons.arrow_downward,
                            color: Theme.of(context).accentColor,
                          ),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          underline: Container(
                            height: 2,
                            color: Theme.of(context).accentColor,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              initVal = newValue;
                              print(initVal);
                            });
                          },
                          items: genders.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Gender: ", style: TextStyle(fontSize: 17),),
                            Text("$initVal", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: FlatButton(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        "Submit New Data",
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
                    FocusScope.of(context).unfocus();
                    updateTravelerData();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
