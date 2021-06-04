import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:travely/Traveler/rated_travel_details.dart';

class RatedTravelsItem extends StatefulWidget {
  final index, searchVal, packageName, ticketId, organizerId, packageId;

  const RatedTravelsItem({
    this.index,
    this.searchVal,
    this.packageName,
    this.ticketId,
    this.organizerId,
    this.packageId,
  });

  @override
  _RatedTravelsItemState createState() => _RatedTravelsItemState();
}

class _RatedTravelsItemState extends State<RatedTravelsItem> {
  showRatedPackageDetails() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return RatedTravelsItemsDetails(
        ticketId: widget.ticketId,
        organizerId: widget.organizerId,
        packageId: widget.packageId,
        packageName: widget.packageName,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          showRatedPackageDetails();
        },
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(35)),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).accentColor,
                Colors.white,
              ],
            ),
          ),
          child: Row(
            children: [
              Card(
                color: Theme.of(context).accentColor,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text(
                    "${widget.index + 1}",
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
              ),
              SizedBox(width: 5),
              SizedBox(width: 15),
              Expanded(
                child: widget.searchVal == ""
                    ? Text(
                        widget.packageName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : SubstringHighlight(
                        text: widget.packageName,
                        term: widget.searchVal,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'Raleway'),
                      ),
              ),
              Icon(
                Icons.arrow_forward_ios,
              ),
            ],
          ),
        ));
  }
}
