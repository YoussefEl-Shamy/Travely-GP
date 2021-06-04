import 'package:flutter/material.dart';
import 'package:travely/Service provider/package_details.dart';

class PackageItem extends StatefulWidget {
  final imageUrl,
      packageName,
      packageId,
      price,
      index,
      originalCurrency,
      currencyConverterVal;

  PackageItem(
      {this.imageUrl,
      this.packageName,
      this.packageId,
      this.price,
      this.index,
      this.originalCurrency,
      this.currencyConverterVal});

  @override
  _PackageItemState createState() => _PackageItemState();
}

class _PackageItemState extends State<PackageItem> {
  var organizerName;
  var price;

  showPackageDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: ((_) {
        return PackageDetails(
          packageId: widget.packageId,
        );
      }),
    ));
  }

  @override
  void initState() {
    super.initState();
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
        child: Row(
          children: [
            Text(
              "${widget.index + 1}.",
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              width: 5
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
                  Text(
                    widget.packageName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text("${price.toStringAsFixed(2)} ${widget.originalCurrency}"),
                ],
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
