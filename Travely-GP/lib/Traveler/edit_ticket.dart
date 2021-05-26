import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTicket extends StatefulWidget {
  final ticketId, packageId;

  const EditTicket({this.ticketId, this.packageId});

  @override
  _EditTicketState createState() => _EditTicketState();
}

class _EditTicketState extends State<EditTicket> {
  TextEditingController ticketsController = TextEditingController();
  var numberOfAvailableTickets,
      packageName,
      description,
      finalPrice,
      startDate,
      endDate,
      bookedTicketsNum,
      oldNewNumOfTicketsDiff,
      newTicketsPrice;
  var ff = FirebaseFirestore.instance;

  getNumberOfTickets() {
    return StreamBuilder(
      stream: ff.collection("packages").doc(widget.packageId).snapshots(),
      builder: (ctx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(),
          );
        }

        var data = snapShot.data;
        numberOfAvailableTickets = data['numOfTickets'];
        return Text("Number of available tickets: $numberOfAvailableTickets");
      },
    );
  }

  buildListTile(Icon icon, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(35)),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Colors.white,
            ],
          )),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: icon,
        ),
        title: Text(
          text,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }

  getPackageDetails() {
    return StreamBuilder(
      stream: ff.collection("packages").doc(widget.packageId).snapshots(),
      builder: (ctx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        var data = snapShot.data;
        packageName = data['packageName'];
        description = data['description'];
        var start = data['startDate'];
        var end = data['endDate'];
        var price = data['price'];
        var startDate = DateTime.parse(start.toDate().toString());
        var endDate = DateTime.parse(end.toDate().toString());
        var originalCurrency = data['originalCurrency'];
        var currencyConverterVal = data['currencyConverterVal'];
        finalPrice = price * currencyConverterVal;
        return Column(
          children: [
            buildListTile(Icon(Icons.card_travel), "$packageName"),
            buildListTile(Icon(Icons.description), "$description"),
            buildListTile(Icon(Icons.date_range),
                "${startDate.day}/${startDate.month}/${startDate.year}"),
            buildListTile(Icon(Icons.date_range_outlined),
                "${endDate.day}/${endDate.month}/${endDate.year}"),
            buildListTile(
              Icon(Icons.attach_money),
              "${finalPrice.toStringAsFixed(2)} $originalCurrency",
            ),
            SizedBox(height: 28),
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
                      "Confirm",
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
                  updateTickets();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  getCurrentNumOfTickets() {
    return StreamBuilder(
      stream:
          ff.collection("travelersPackages").doc(widget.ticketId).snapshots(),
      builder: (ctx, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(),
          );
        }

        var data = snapShot.data;
        bookedTicketsNum = data['numOfTickets'];
        return Column(
          children: [
            TextField(
              controller: ticketsController..text = bookedTicketsNum.toString(),
              decoration: InputDecoration(
                  labelText: "Number of booked tickets",
                  hintText: "Enter number of tickets you need",
                  prefixIcon: Icon(Icons.airplane_ticket_sharp),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(60),
                      borderSide: BorderSide(color: Colors.redAccent))),
              keyboardType: TextInputType.numberWithOptions(
                  decimal: false, signed: false),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exchanging Tickets"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 15, right: 15),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    getCurrentNumOfTickets(),
                    getNumberOfTickets(),
                  ],
                ),
              ),
              getPackageDetails(),
            ],
          ),
        ),
      ),
    );
  }

  bool ok;

  updateNumberOfTickets() async {
    if (ok) {
      await ff
          .collection("travelersPackages")
          .doc(widget.ticketId)
          .update({"numOfTickets": int.parse(ticketsController.text)});
    }
  }

  updatePackageTickets() async {
    bool isInt;
    try {
      int.parse(ticketsController.text);
      isInt = true;
    } catch (e) {
      isInt = false;
    }

    if (!isInt) {
      final snackBar = SnackBar(
        content: Text('Don\'t enter decimal numbers'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 6),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      ok = false;
    } else if (int.parse(ticketsController.text) > numberOfAvailableTickets) {
      final snackBar = SnackBar(
        content: Text('You cannot book more than available !'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 6),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      ok = false;
    } else if (int.parse(ticketsController.text) < 0) {
      final snackBar = SnackBar(
        content: Text('Enter a positive integer number !'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 6),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      ok = false;
    } else {
      oldNewNumOfTicketsDiff =
          int.parse(ticketsController.text) - bookedTicketsNum;
      await ff.collection("packages").doc(widget.packageId).update(
          {'numOfTickets': numberOfAvailableTickets - oldNewNumOfTicketsDiff});
      ok = true;
    }
  }

  priceHandling() {
    if (ok) {
      oldNewNumOfTicketsDiff > 0
          ? newTicketsPrice = finalPrice * oldNewNumOfTicketsDiff
          : newTicketsPrice =
              (finalPrice * 80 / 100) * (oldNewNumOfTicketsDiff * -1);

      print("New Tickets Price $newTicketsPrice");
    }
  }

  updateTickets() {
    updatePackageTickets().then((_) {
      updateNumberOfTickets().then((_) {
        priceHandling();
        if (ok) {
          Navigator.of(context).pop();
        }
      });
    });
  }
}
