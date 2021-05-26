import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/registration_parameters.dart';
import '../Providers/traveler_providerServices_details_provider.dart';

class Choice extends StatefulWidget {

  @override
  _ChoiceState createState() => _ChoiceState();
}

class _ChoiceState extends State<Choice> {
  int selectedRadio;

  @override
  void initState() {
    super.initState();
    selectedRadio = 0;
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
      Provider.of<RegParam>(context, listen: false).getTravelerOrProvider(selectedRadio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        children: [
          Text(
            "Choose your role",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Color(0xFF007965),height: 5,),
          RadioListTile(
            title: const Text(
              'Traveler',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            value: 1,
            groupValue: selectedRadio,
            onChanged: (value) {
              FocusScope.of(context).unfocus();
              print(value);
              setSelectedRadio(value);
              Provider.of<ShowDetails>(context, listen: false).traveler();
            },
          ),
          RadioListTile(
            title: const Text(
              'Service Provider',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            value: 2,
            groupValue: selectedRadio,
            onChanged: (value) {
              FocusScope.of(context).unfocus();
              print(value);
              setSelectedRadio(value);
              Provider.of<ShowDetails>(context, listen: false).provider();
            },
          ),
        ],
      ),
    );
  }
}
