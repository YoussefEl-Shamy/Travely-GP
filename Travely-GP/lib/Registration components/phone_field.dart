import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travely/Providers/registration_parameters.dart';

class PhoneField extends StatelessWidget {
  final controller;

  PhoneField(this.controller);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(60)),
          ),
          child: CountryCodePicker(
            initialSelection: 'EG',
            showCountryOnly: true,
            onChanged: (newCountry){
              Provider.of<RegParam>(context, listen: false).getDialCode(newCountry.dialCode);
            },
          ),
        ),
        SizedBox(width: 7),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Phone Number",
              hintText: "Enter your phone number",
              prefixIcon: Icon(Icons.phone_android),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(60),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
        ),
      ],
    );
  }
}
