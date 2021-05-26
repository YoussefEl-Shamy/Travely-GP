import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/registration_parameters.dart';

class PAD extends StatefulWidget {
  @override
  _PADState createState() => _PADState();
}

String initVal = 'Travels organizer';
List<String> roles = ["Travels organizer", "Hotel", "Airport"];

class _PADState extends State<PAD> {
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
                Provider.of<RegParam>(context, listen: false).getServiceProvider(initVal);
                print(initVal);
              });
            },
            items: roles.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Role: ", style: TextStyle(fontSize: 17),),
              Text("$initVal", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
            ],
          ),
          SizedBox(height: 7,)
        ],
      ),
    );
  }
}
