import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:travely/Screens/loading.dart';
import 'package:travely/Screens/loading_wave.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:travely/Service%20provider/update_package.dart';

class PackageDetails extends StatefulWidget {
  final packageId;

  PackageDetails({
    this.packageId,
  });

  @override
  _PackageDetailsState createState() => _PackageDetailsState();
}

Color fc = Color(0xFFf58634);

class _PackageDetailsState extends State<PackageDetails> {
  String packageName, organizerName, organizerEmail, imageUrl;
  var image1, image2, image3, image4, image5, image6, image7;
  List<String> images = [];
  var package,
      description,
      price,
      originalCurrency,
      currencyConverterVal,
      finalPrice,
      startDate,
      endDate;
  bool _isLoading = false;
  int _currentImage;

  getPackageName() {
    package = FirebaseFirestore.instance
        .collection("packages")
        .doc(widget.packageId)
        .snapshots();
    return StreamBuilder(
      stream: package,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWave();
        }
        packageName = snapshot.data['packageName'];
        return Text(packageName);
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

  getPackageDetails() {
    return StreamBuilder(
      stream: package,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        packageName = snapshot.data['packageName'];
        description = snapshot.data['description'];
        var start = snapshot.data['startDate'];
        var end = snapshot.data['endDate'];
        price = snapshot.data['price'];
        var rate = snapshot.data['rate'];
        image1 = snapshot.data['images'][0];
        currencyConverterVal = snapshot.data['currencyConverterVal'];
        originalCurrency = snapshot.data['originalCurrency'];
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
          image4 = snapshot.data['images'][4];
        } catch (e) {
          print(e);
        }
        try {
          image4 = snapshot.data['images'][5];
        } catch (e) {
          print(e);
        }
        try {
          image4 = snapshot.data['images'][6];
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
        print("images list length is: ${images.length}");
        print("Type of images list: ${images.runtimeType}");
        startDate = DateTime.parse(start.toDate().toString());
        endDate = DateTime.parse(end.toDate().toString());
        finalPrice = price * currencyConverterVal;
        return Column(
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
                          ),
                        ),
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
                          ),
                        ),
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
                  SizedBox(height: 15),
                  SmoothStarRating(
                    rating: rate.toDouble(),
                    size: 35,
                    isReadOnly: true,
                    color: fc,
                    borderColor: fc,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Package rate: "),
                      Text(
                        "$rate",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    getPackageName();
    getPackageDetails();
  }

  deletePackage() {
    setState(() {
      _isLoading = true;
    });

    FirebaseFirestore.instance
        .collection("packages")
        .doc(widget.packageId)
        .delete();

    deleteImage(imageUrl).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  deleteImage(String imageUrl) async {
    if (imageUrl != null) {
      var firebaseStorageRef = FirebaseStorage.instance.refFromURL(imageUrl);

      await firebaseStorageRef.delete();
    }
  }

  showDeleteDialog(BuildContext buildContext) {
    showDialog(
      context: this.context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Package!"),
        content: Text("Are you sure you want to delete that package ?"),
        actions: [
          FlatButton(
            onPressed: () {
              deletePackage();
              setState(() {
                _isLoading = false;
              });
              Navigator.of(ctx).pop();
              Navigator.of(buildContext).pop();
            },
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.red),
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

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: getPackageName(),
              actions: [
                IconButton(
                  icon: Icon(Icons.update),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      print("Start date: $startDate");
                      return UpdatePackage(
                        packageName: packageName,
                        packageDescription: description,
                        startDate: startDate,
                        endDate: endDate,
                        packageId: widget.packageId,
                        packagePrice: price,
                        images: images,
                      );
                    }));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever),
                  color: Colors.white,
                  onPressed: () {
                    showDeleteDialog(context);
                  },
                ),
              ],
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
