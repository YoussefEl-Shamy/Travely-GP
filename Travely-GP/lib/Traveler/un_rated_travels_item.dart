import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:travely/Traveler/un_rated_travel_details.dart';

class UnRatedTravelsItem extends StatefulWidget {
  final index,
      searchVal,
      packageName,
      packageId,
      ticketId,
      description,
      price,
      organizerId,
      categories;

  const UnRatedTravelsItem({
    this.index,
    this.searchVal,
    this.packageName,
    this.packageId,
    this.ticketId,
    this.description,
    this.price,
    this.categories,
    this.organizerId,
  });

  @override
  _UnRatedTravelsItemState createState() => _UnRatedTravelsItemState();
}

class _UnRatedTravelsItemState extends State<UnRatedTravelsItem> {
  showUnratedPackageDetails() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return UnRatedTravelDetails(
        packageId: widget.packageId,
        ticketId: widget.ticketId,
        organizerId: widget.organizerId,
        packageName: widget.packageName,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showUnratedPackageDetails();
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
      ),
    );
  }
}
