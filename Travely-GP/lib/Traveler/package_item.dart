import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:travely/Traveler/package_details.dart';
import 'package:travely/Screens/loading_wave.dart';

class PackageItem extends StatefulWidget {
  final imageUrl,
      packageName,
      categories,
      packageId,
      organizerId,
      index,
      description,
      price,
      searchVal,
      currencyConverterVal,
      originalCurrency,
      actor;

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
    this.categories, this.actor,
  });

  @override
  _PackageItemState createState() => _PackageItemState();
}

class _PackageItemState extends State<PackageItem> {
  var organizerName;
  double price;

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
        var rate = snapshot.data['rate'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("$organizerName"),
            SizedBox(
              height: 6,
            ),
            Row(
              children: [
                Icon(
                  Icons.star_rate_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Text(
                    "${rate.toDouble()}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  showPackageDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: ((_) {
        return PackageDetails(
          organizerId: widget.organizerId,
          packageId: widget.packageId,
          packageName: widget.packageName,
          description: widget.description,
          price: widget.price,
          categories: widget.categories,
          actor: widget.actor
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
    price = widget.price.toDouble() * widget.currencyConverterVal.toDouble();
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
                Expanded(
                  child: Column(
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
                ),
                Icon(
                  Icons.arrow_forward_ios,
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
                      "${price.toDouble().toStringAsFixed(2)} ${widget.originalCurrency}",
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
