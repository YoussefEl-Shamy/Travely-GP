import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:travely/Admin/provider_details.dart';
import 'package:travely/Admin/traveler_details.dart';

class UserUnit extends StatefulWidget {
  final String imageUrl, email, username, userId, role, searchVal;

  const UserUnit({
    this.role,
    this.userId,
    this.imageUrl,
    this.email,
    this.username,
    this.searchVal,
  });

  @override
  _UserUnitState createState() => _UserUnitState();
}

class _UserUnitState extends State<UserUnit> {
  showTravelerDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: ((_) {
        return TravelerDetails(
          travelerId: widget.userId,
        );
      }),
    ));
  }

  showProviderDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: ((_) {
        return ProviderDetails(
          providerId: widget.userId,
        );
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.role == "travelers"
            ? showTravelerDetails(context)
            : showProviderDetails(context);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 5,
                ),
                CircleAvatar(
                  backgroundColor: Colors.black38,
                  radius: 35,
                  backgroundImage: NetworkImage(widget.imageUrl),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.searchVal == ""
                          ? Text(
                        widget.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                          : SubstringHighlight(
                        text: widget.username,
                        term: widget.searchVal,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Raleway'),
                      ),
                      SizedBox(height: 14),
                      widget.searchVal == ""
                          ? Text(widget.email)
                          : SubstringHighlight(
                        text: widget.email,
                        term: widget.searchVal,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
