import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:travely/Auth/auth_screen.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Screens/loading_wave.dart';

class PackageDetails extends StatefulWidget {
  final organizerId,
      packageId,
      packageName,
      description,
      price,
      categories,
      actor;

  PackageDetails({
    this.organizerId,
    this.packageId,
    this.packageName,
    this.description,
    this.price,
    this.categories,
    this.actor,
  });

  @override
  _PackageDetailsState createState() => _PackageDetailsState();
}

Color fc = Color(0xFFf58634);

class _PackageDetailsState extends State<PackageDetails> {
  String packageName, organizerName, organizerEmail, organizerPhone, imageUrl;
  TextEditingController ticketsController = TextEditingController();
  var image1, image2, image3, image4, image5, image6, image7;
  var category1,
      category2,
      category3,
      category4,
      category5,
      category6,
      category7,
      category8;
  List<String> images = [];
  List<String> categories = [];
  var package, userId, ff = FirebaseFirestore.instance, numberOfBookedTickets;
  var originalCurrency,
      currencyConverterVal,
      finalPrice,
      totalPriceOfTickets = 0.0;
  int _currentImage;
  bool _isLoading = true, _isBooked;

  getPackageName() {
    package = ff.collection("packages").doc(widget.packageId).snapshots();
    return StreamBuilder(
      stream: package,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LinearProgressIndicator();
        }
        packageName = snapshot.data['packageName'];
        return Text(packageName);
      },
    );
  }

  getOrganizerDetails() {
    var organizer =
        ff.collection("service providers").doc(widget.organizerId).snapshots();
    return StreamBuilder(
      stream: organizer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              Center(child: LoadingWave()),
            ],
          );
        }
        organizerName = snapshot.data['username'];
        organizerEmail = snapshot.data['email'];
        organizerPhone = snapshot.data['phone'];
        print("organizerName: $organizerName");
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.supervisor_account),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      organizerName,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      organizerEmail,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      organizerPhone,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  imageDialog(String imageUrl) {
    return InteractiveViewer(
      child: Dialog(
        child: Container(
          width: double.infinity,
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(Icons.cancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  var snapshotDocs;

  getDocs() async {
    print("Hiiiiiiiiiiiiiiiiii");
    print(userId);
    print(widget.packageId);
    snapshotDocs = userId != null
        ? await ff
            .collection("travelersPackages")
            .where("travelerId", isEqualTo: userId)
            .where("packageId", isEqualTo: widget.packageId)
            .get()
        : await ff
            .collection("travelersPackages")
            .where("packageId", isEqualTo: widget.packageId)
            .get();
    print("inside getDocs");
  }

  checkBooked() async {
    await getDocs().then((_) {
      if (snapshotDocs.docs.length == 0) {
        setState(() {
          _isBooked = false;
        });
      } else {
        setState(() {
          _isBooked = true;
        });
      }
      print("_isBooked: $_isBooked");
      setState(() {
        _isLoading = false;
      });
    });
  }

  _bookPackage() async {
    var id = ff.collection("travelersPackages").doc().id.toString();
    await ff.collection("travelersPackages").doc(id).set({
      "ticketId": id,
      "packageId": widget.packageId,
      "travelerId": userId,
      "numOfTickets": numberOfBookedTickets,
      "organizerId": widget.organizerId,
      "packageName": widget.packageName,
      "description": widget.description,
      "price": widget.price,
      "categories": widget.categories,
      "rate": 0.0,
    });
    final snackBar = SnackBar(
      content: Row(
        children: [
          Text('Total price: '),
          Text(
            '$totalPriceOfTickets',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 6),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  var numOfAvailableTickets;

  updateNumOfAvailableTickets() {
    return ff
        .collection("packages")
        .doc(widget.packageId)
        .update({'numOfTickets': numOfAvailableTickets - numberOfBookedTickets})
        .then((value) {})
        .catchError((e) => print("Cannot be updated: $e"));
  }

  showNumberOfTicketsDialog() {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Number of tickets"),
        content: Container(
          height: 200,
          child: Column(
            children: [
              TextField(
                controller: ticketsController,
                decoration: InputDecoration(
                    labelText: "Number of tickets",
                    hintText: "Enter number of tickets you need",
                    prefixIcon: Icon(Icons.airplane_ticket_sharp),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(60),
                        borderSide: BorderSide(color: Colors.redAccent))),
                keyboardType: TextInputType.numberWithOptions(
                    decimal: false, signed: false),
                onChanged: (newValue) {
                  totalPriceOfTickets =
                      double.parse(finalPrice.toStringAsFixed(2)) *
                          double.parse(ticketsController.text);
                  print("Total Price: $totalPriceOfTickets");
                },
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  Text("Note: the Number of available tickets is"),
                  StreamBuilder(
                    stream: ff
                        .collection("packages")
                        .where('packageId', isEqualTo: widget.packageId)
                        .snapshots(),
                    builder: (ctx, snapShot) {
                      if (snapShot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      final docs = snapShot.data.docs;
                      print("Docs length and it should be 1: ${docs.length}");
                      return Container(
                        height: 30,
                        width: 30,
                        child: ListView.builder(
                          itemBuilder: (ctx, index) {
                            numOfAvailableTickets = docs[index]["numOfTickets"];
                            return Text("$numOfAvailableTickets");
                          },
                          itemCount: docs.length,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () {
              bool isEmptyOrNotValid;
              try {
                print("TRY");
                double.parse(ticketsController.text.trim()).floor();
                isEmptyOrNotValid = false;
              } catch (e) {
                print("CATCH");
                isEmptyOrNotValid = true;
              }

              if (isEmptyOrNotValid == true) {
                final snackBar = SnackBar(
                  content: Text("Enter valid number"),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 5),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                numberOfBookedTickets =
                    double.parse(ticketsController.text.trim()).floor();
                var totalNumOfAvailableTickets =
                    numOfAvailableTickets - numberOfBookedTickets;

                if (totalNumOfAvailableTickets > 0) {
                  setState(() {
                    _isBooked = true;
                  });

                  _bookPackage();
                  updateNumOfAvailableTickets();
                  Navigator.of(ctx).pop();
                } else {
                  final snackBar = SnackBar(
                    content: Text('You cannot book more than available !'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 6),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }
            },
            child: Text(
              "Confirm",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  showLoginDialog() {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Notice !"),
        content: Text("You have to be logged in to book travels"),
        actions: [
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) {
                return AuthScreen(isFromPackageDetails: true);
              }));
            },
            child: Text(
              "Go to login page",
              style:
              TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text(
              "Close",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  getPackageDetails() {
    return StreamBuilder(
      stream: package,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWave();
        }
        packageName = snapshot.data['packageName'];
        var description = snapshot.data['description'];
        var start = snapshot.data['startDate'];
        var end = snapshot.data['endDate'];
        var price = snapshot.data['price'];
        currencyConverterVal = snapshot.data['currencyConverterVal'];
        originalCurrency = snapshot.data['originalCurrency'];
        image1 = snapshot.data['images'][0];
        try {
          image2 = snapshot.data['images'][1];
        } catch (e) {
          print(e);
        }
        try {
          image3 = snapshot.data['images'][2];
        } catch (e) {
          print(e);
        }
        try {
          image4 = snapshot.data['images'][3];
        } catch (e) {
          print(e);
        }
        try {
          image5 = snapshot.data['images'][4];
        } catch (e) {
          print(e);
        }
        try {
          image6 = snapshot.data['images'][5];
        } catch (e) {
          print(e);
        }
        try {
          image7 = snapshot.data['images'][6];
        } catch (e) {
          print(e);
        }
        images.add(image1);
        if (image2 != null) images.add(image2);
        if (image3 != null) images.add(image3);
        if (image4 != null) images.add(image4);
        if (image5 != null) images.add(image5);
        if (image6 != null) images.add(image6);
        if (image7 != null) images.add(image7);

        category1 = snapshot.data['categories'][0];
        try {
          category2 = snapshot.data['categories'][1];
        } catch (e) {
          print(e);
        }
        try {
          category3 = snapshot.data['categories'][2];
        } catch (e) {
          print(e);
        }
        try {
          category4 = snapshot.data['categories'][3];
        } catch (e) {
          print(e);
        }
        try {
          category5 = snapshot.data['categories'][4];
        } catch (e) {
          print(e);
        }
        try {
          category6 = snapshot.data['categories'][5];
        } catch (e) {
          print(e);
        }
        try {
          category7 = snapshot.data['categories'][6];
        } catch (e) {
          print(e);
        }
        try {
          category8 = snapshot.data['categories'][7];
        } catch (e) {
          print(e);
        }
        categories.add(category1);
        if (category2 != null) categories.add(category2);
        if (category3 != null) categories.add(category3);
        if (category4 != null) categories.add(category4);
        if (category5 != null) categories.add(category5);
        if (category6 != null) categories.add(category6);
        if (category7 != null) categories.add(category7);
        if (category8 != null) categories.add(category8);
        print("images list length is: ${images.length}");
        print("categories list length is: ${categories.length}");
        var startDate = DateTime.parse(start.toDate().toString());
        var endDate = DateTime.parse(end.toDate().toString());
        finalPrice = price * currencyConverterVal;
        return Column(
          children: [
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(35),
                    bottomLeft: Radius.circular(35),
                  ),
                  child: images.length > 1
                      ? CarouselSlider.builder(
                          options: CarouselOptions(
                              enlargeCenterPage: true,
                              autoPlayAnimationDuration: Duration(seconds: 10),
                              height: 250,
                              initialPage: 0,
                              onPageChanged: (index, _) {
                                _currentImage = index;
                                print("Current image: $_currentImage");
                              }),
                          itemBuilder:
                              (BuildContext context, int index, int realIndex) {
                            return InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => imageDialog(images[index]));
                              },
                              child: Container(
                                height: 250,
                                width: double.infinity,
                                color: Colors.black38,
                                child: Image.network(
                                  images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          itemCount: images.length,
                        )
                      : InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (_) => imageDialog(images[0]));
                          },
                          child: Container(
                            height: 250,
                            width: double.infinity,
                            color: Colors.black38,
                            child: Image.network(
                              images[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, top: 25),
                  child: Column(
                    children: [
                      getOrganizerDetails(),
                      Divider(
                        thickness: 4,
                        color: Colors.black38,
                        height: 34,
                        indent: 10,
                        endIndent: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.description_rounded),
                            SizedBox(width: 7),
                            Expanded(
                                child: Text(
                              "$description",
                              style: TextStyle(fontSize: 20),
                            )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.monetization_on_rounded),
                            SizedBox(width: 7),
                            Expanded(
                                child: Text(
                              "${finalPrice.toStringAsFixed(2)} $originalCurrency",
                              style: TextStyle(fontSize: 20),
                            )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.date_range),
                            SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                "${startDate.day}/${startDate.month}/${startDate.year}  (${startDate.hour}:${startDate.minute})",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.date_range_outlined),
                            SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                "${endDate.day}/${endDate.month}/${endDate.year}  (${endDate.hour}:${endDate.minute})",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      ExpansionTile(
                        textColor: fc,
                        iconColor: fc,
                        title: Text(
                          "Package types",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Show the package types"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "- ${categories[0]}",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          if (category2 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[1]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          if (category3 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[2]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          if (category4 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[3]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          if (category5 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[4]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          if (category6 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[5]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          if (category7 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[6]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          if (category8 != null)
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "- ${categories[7]}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            DateTime.now().difference(startDate) > Duration(days: 0)
                ? Text(
                    "Out of date!",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )
                : _isBooked == false
                    ? FlatButton(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Book Travel Package",
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Theme.of(context).accentColor,
                        splashColor: Colors.red,
                        onPressed: () {
                          if (FirebaseAuth.instance.currentUser.uid != null) {
                            print(userId);
                            showNumberOfTicketsDialog();
                          } else {
                            showLoginDialog();
                          }
                        },
                      )
                    : Text(
                        "Booked Successfully!",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
            SizedBox(height: 25),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser.uid != null
        ? FirebaseAuth.instance.currentUser.uid
        : null;
    checkBooked();
    getPackageName();
    getPackageDetails();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == true
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: getPackageName(),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: getPackageDetails(),
                  ),
                ],
              ),
            ),
          );
  }
}
