import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Traveler/traveler_home_page.dart';

class UnRatedTravelDetails extends StatefulWidget {
  final packageId, ticketId, organizerId, packageName;

  const UnRatedTravelDetails({
    this.packageId,
    this.ticketId,
    this.organizerId,
    this.packageName,
  });

  @override
  _UnRatedTravelDetailsState createState() => _UnRatedTravelDetailsState();
}

class _UnRatedTravelDetailsState extends State<UnRatedTravelDetails> {
  var travelerId = FirebaseAuth.instance.currentUser.uid;
  Color fc = Color(0xFFf58634);
  bool _isLoading = false;
  var organizerId,
      rate,
      numOfTickets,
      packageName,
      description,
      price,
      categories;
  var packageRate = 0.0;

  getPackageDetails() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("unRatedTravels")
            .doc(widget.ticketId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          var doc = snapshot.data;
          packageName = doc['packageName'];
          numOfTickets = doc['numOfTickets'];
          rate = doc['rate'];
          description = doc['description'];
          price = doc['price'];
          categories = doc['categories'];
          organizerId = doc['organizerId'];

          return Column(
            children: [
              Center(
                child: Text(
                  "Rate The Package.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              SmoothStarRating(
                rating: rate.toDouble(),
                size: 45,
                color: fc,
                borderColor: fc,
                onRated: (rate) {
                  packageRate = rate;
                  print("Package Rate: $packageRate");
                },
              ),
              SizedBox(height: 35),
              ListTile(
                title: Text(packageName),
                leading: Icon(Icons.card_travel),
              ),
              ListTile(
                title: Text(
                    '$numOfTickets ${numOfTickets == 1 ? "Ticket" : "Tickets"}'),
                leading: Icon(Icons.airplane_ticket_outlined),
              ),
              ListTile(
                title: Text(description),
                leading: Icon(Icons.description),
              ),
              ListTile(
                title: Text("$price"),
                leading: Icon(Icons.attach_money),
              ),
              Stack(
                children: [
                  Container(
                    height: 50,
                    padding: EdgeInsets.only(right: 8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(35)),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Theme.of(context).accentColor,
                          Color.fromRGBO(255, 255, 255, 0),
                        ],
                      ),
                    ),
                    child: categories.length > 2
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                              ),
                            ],
                          )
                        : Container(),
                  ),
                  Container(
                    height: 50,
                    padding: EdgeInsets.only(right: 30),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 160,
                          child: Wrap(
                            children: [
                              ListTile(
                                title: Text("${categories[index]}"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          );
        },
      ),
    );
  }

  getOrganizerDetails() {
    print(organizerId);
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("service providers")
            .doc(widget.organizerId)
            .snapshots(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );

          var data = snapShot.data;
          var organizerName = data["username"];
          var email = data["email"];
          var phone = data["phone"];
          var rate = data["rate"];
          return ExpansionTile(
            textColor: fc,
            iconColor: fc,
            title: Text(
              "Organizer Details",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Show more details about organizer"),
            children: [
              ListTile(
                title: Text(organizerName),
                leading: Icon(Icons.person),
              ),
              ListTile(
                title: Text(email),
                leading: Icon(Icons.email),
              ),
              ListTile(
                title: Text(phone),
                leading: Icon(Icons.phone),
              ),
              ListTile(
                title: Text("$rate"),
                leading: Icon(Icons.star),
              ),
            ],
          );
        },
      ),
    );
  }

  moveToRated(
      {String organizerId,
      String packageId,
      double rate,
      String travelerId,
      String packageName,
      double price,
      String description,
      int numOfTickets,
      categories,
      String ticketId}) async {
    await FirebaseFirestore.instance
        .collection("ratedTravels")
        .doc(ticketId)
        .set({
      "organizerId": organizerId,
      "packageId": packageId,
      "rate": rate,
      "ticketId": ticketId,
      "travelerId": travelerId,
      "packageName": packageName,
      "description": description,
      "price": price,
      "categories": categories,
    });
  }

  updateOrganizerRate() {
    print("Organizer ID: $organizerId");
    FirebaseFirestore.instance
        .collection("service providers")
        .doc(organizerId)
        .get()
        .then((value) {
      print("We are in");
      var currentNumOfReviews = value['numOfReviews'];
      var currentSumOfRates = value['sumOfRates'];
      var numOfReviews = currentNumOfReviews + 1;
      var sumOfRates = currentSumOfRates + packageRate;
      double totalRate = sumOfRates / numOfReviews;

      if (totalRate - totalRate.floorToDouble() < 0.5) {
        if ((totalRate - totalRate.floorToDouble()) > 0.2) {
          totalRate = totalRate.floorToDouble() + 0.5;
        } else {
          totalRate = totalRate.floorToDouble();
        }
      } else if (totalRate - totalRate.floor() > 0.5) {
        if ((totalRate - totalRate.floorToDouble()) > 0.75) {
          totalRate = totalRate.floorToDouble() + 1.0;
        } else {
          totalRate = totalRate.floorToDouble() + 0.5;
        }
      }

      FirebaseFirestore.instance
          .collection("service providers")
          .doc(organizerId)
          .update({
        "rate": totalRate,
        "numOfReviews": numOfReviews,
        "sumOfRates": sumOfRates,
      });
    });
  }

  deleteFromUnrated() {
    FirebaseFirestore.instance
        .collection("unRatedTravels")
        .doc(widget.ticketId)
        .delete();
    setState(() {
      _isLoading = false;
    });
  }

  submit() {
    updateOrganizerRate();
    moveToRated(
        organizerId: organizerId,
        packageId: widget.packageId,
        rate: packageRate,
        travelerId: travelerId,
        packageName: packageName,
        price: price,
        description: description,
        categories: categories,
        ticketId: widget.ticketId,
        numOfTickets: numOfTickets);
    deleteFromUnrated();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: Text(widget.packageName),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  getPackageDetails(),
                  getOrganizerDetails(),
                  FlatButton(
                      child: Text(
                        "Rate",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: fc,
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => FirstPage(),
                          ),
                          (route) => false,
                        );
                        submit();
                      }),
                ],
              ),
            ),
          );
  }
}
