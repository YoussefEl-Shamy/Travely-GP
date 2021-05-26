import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:travely/Traveler/package_details.dart';
import 'package:travely/Screens/loading_wave.dart';

class PackageItem extends StatefulWidget {
  final imageUrl,
      packageName,
      packageId,
      organizerId,
      index,
      description,
      price,
      searchVal,
      currencyConverterVal,
      originalCurrency;

  PackageItem({
    this.imageUrl,
    this.packageName,
    this.organizerId,
    this.packageId,
    this.index,
    this.description,
    this.price,
    this.searchVal,
    this.originalCurrency,
    this.currencyConverterVal,
  });

  @override
  _PackageItemState createState() => _PackageItemState();
}

class _PackageItemState extends State<PackageItem> {
  var organizerName;
  var price;

  getOrganizerName() {
    var organizer = FirebaseFirestore.instance
        .collection("service providers")
        .doc(widget.organizerId)
        .snapshots();
    return StreamBuilder(
      stream: organizer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWave();
        }
        organizerName = snapshot.data['username'];
        return Text(organizerName);
      },
    );
  }

  showPackageDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: ((_) {
        return PackageDetails(
          organizerId: widget.organizerId,
          packageId: widget.packageId,
        );
      }),
    ));
  }

  @override
  void initState() {
    super.initState();
    getOrganizerName();
  }

  @override
  Widget build(BuildContext context) {
    price = widget.price * widget.currencyConverterVal;
    return InkWell(
      onTap: () {
        showPackageDetails(context);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Text(
                      "${widget.index + 1}.",
                      style: TextStyle(color: Colors.black),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.black38,
                      radius: 35,
                      backgroundImage: NetworkImage(widget.imageUrl),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.searchVal == ""
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
                        SizedBox(height: 14),
                        getOrganizerName(),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text("More Info."),
              leading: Icon(Icons.info),
              children: [
                ListTile(
                  title: Text(
                    "Description\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: widget.searchVal == ""
                      ? Text(widget.description,
                          style: TextStyle(
                            fontSize: 18,
                          ))
                      : SubstringHighlight(
                          text: widget.description,
                          term: widget.searchVal,
                          textStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontFamily: 'Raleway'),
                        ),
                  leading: Icon(Icons.description),
                ),
                Divider(
                  thickness: 1,
                  color: Theme.of(context).primaryColor,
                  endIndent: 10,
                  indent: 10,
                ),
                ListTile(
                  title: Text(
                    "Price\n",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      "${price.toStringAsFixed(2)} ${widget.originalCurrency}",
                      style: TextStyle(
                        fontSize: 18,
                      )),
                  leading: Icon(Icons.attach_money_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
