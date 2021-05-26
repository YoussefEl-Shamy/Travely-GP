import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/registration_parameters.dart';

class TAD extends StatefulWidget {
  @override
  _TADState createState() => _TADState();
}

class _TADState extends State<TAD> {
  String initVal = 'Male';
  List<String> genders = ["Male", "Female"];

  var pickedTime;

  void datePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    ).then((value) {
      if (value == null) {
        return 0;
      }
      setState(() {
        pickedTime = value;
        Provider.of<RegParam>(context, listen: false).getDateOfBirth(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
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
                Provider.of<RegParam>(context, listen: false).getGender(initVal);
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
          SizedBox(height: 10),
          RaisedButton(
            color: Color(0xFF007965),
            textColor: Colors.white,
            child: pickedTime == null
                ? Text("Pick your birth date")
                : Text("${DateFormat.yMMMd().format(pickedTime)}"),
            onPressed: datePicker,
          ),
        ],
      ),
    );
  }
}
