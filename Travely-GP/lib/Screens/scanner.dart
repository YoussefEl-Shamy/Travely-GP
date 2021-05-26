import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:travely/Screens/loading.dart';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  var barcode = "Barcode Result";
  var color = Color(0xFF007965);
  var _isLoading = false, isExist = false;

  scanBarcode() async {
    print("Barcode Scanner");
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
          "#f58634", "Cancel", true, ScanMode.BARCODE);
      if (!mounted) return;
      setState(() {
        this.barcode = barcode;
      });
    } on PlatformException {
      barcode = "Failed to get platform version";
    } finally {
      print("Barcode: $barcode");
      checkExistence();
    }
  }

  var snapshotDocs;

  getDocs() async {
    snapshotDocs = await FirebaseFirestore.instance
        .collection("packages")
        .where("packageId", isEqualTo: barcode)
        .get();
    print("inside getDocs");
  }

  checkExistence() async {
    await getDocs().then((_) {
      if (snapshotDocs.docs.length == 0) {
        setState(() {
          isExist = false;
        });
      } else {
        setState(() {
          isExist = true;
        });
      }
      print("isExist: $isExist");
      setState(() {
        _isLoading = false;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: barcode != "Barcode Result" &&
                    barcode != "Failed to get platform version" &&
                    barcode != "-1" &&
                    isExist
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection("packages")
                            .doc(barcode)
                            .snapshots(),
                        builder: (ctx, snapShot) {
                          if (snapShot.connectionState ==
                              ConnectionState.waiting)
                            return Center(child: CircularProgressIndicator());

                          var data = snapShot.data;
                          var start = data['startDate'];
                          var end = data['endDate'];
                          var startDate = DateTime.parse(start.toDate().toString());
                          var endDate = DateTime.parse(end.toDate().toString());
                          var originalCurrency = data['originalCurrency'];
                          var price = data['price'];
                          var currencyConverterVal = data['currencyConverterVal'];
                          var finalPrice = price * currencyConverterVal;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                buildListTile(Icon(Icons.card_travel),
                                    "${data['packageName']}"),
                                buildListTile(Icon(Icons.description_outlined),
                                    "${data['description']}"),
                                buildListTile(Icon(Icons.date_range),
                                    "${startDate.day}/${startDate.month}/${startDate.year}"),
                                buildListTile(Icon(Icons.date_range_outlined),
                                    "${endDate.day}/${endDate.month}/${endDate.year}"),
                                buildListTile(
                                  Icon(Icons.attach_money),
                                  "${finalPrice.toStringAsFixed(2)} $originalCurrency",
                                ),
                                SizedBox(height: 25),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 30),
                                  child: InkWell(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF007965),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.qr_code_scanner,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Scan Other Barcode",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: scanBarcode,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        barcode,
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 25),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: InkWell(
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xFF007965),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Scan Barcode",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            onTap: scanBarcode,
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }
}
