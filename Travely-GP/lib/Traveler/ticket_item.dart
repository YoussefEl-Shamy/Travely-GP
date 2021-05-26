import 'package:barcode_widget/barcode_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travely/Traveler/edit_ticket.dart';

class Ticket extends StatefulWidget {
  final ticketsNum, packageId, organizerId, ticketId;

  const Ticket({this.ticketsNum, this.packageId, this.organizerId, this.ticketId});

  @override
  _TicketState createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  var organizerName, packageName, startDate, endDate;

  getOrganizerName(){
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("service providers")
            .doc(widget.organizerId)
            .snapshots(),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          var data = snapShot.data;
          organizerName = data['username'];
          return Text(
            "Organizer Name: $organizerName",
            style: TextStyle(fontSize: 18),
          );
        });
  }

  getPackageDetails() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("packages")
            .doc(widget.packageId)
            .snapshots(),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          var data = snapShot.data;
          print("Data: $data");
          packageName = data['packageName'];
          print("Package Name: $packageName");
          var initStartDate = data['startDate'];
          var initEndDate = data['endDate'];
          startDate = DateTime.parse(initStartDate.toDate().toString());
          endDate = DateTime.parse(initEndDate.toDate().toString());
          return Column(
            children: [
              Text(
                "Package Name: $packageName",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 5),
              getOrganizerName(),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "From: ${startDate.day}/${startDate.month}/${startDate.year}",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "To: ${endDate.day}/${endDate.month}/${endDate.year}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: InkWell(
        onTap: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (_){
            return EditTicket(ticketId: widget.ticketId,packageId: widget.packageId,);
          }));
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 25),
          child: ClipPath(
            clipper: DolDurmaClipper(holeRadius: 32),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF9FF7A), Color(0xFFD2DA1D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: widget.packageId,
                      height: 70,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "⎯  ${widget.ticketsNum} ${widget.ticketsNum > 1 ? "Tickets" : "Ticket"}  ⎯",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 5),
                  getPackageDetails(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DolDurmaClipper extends CustomClipper<Path> {
  DolDurmaClipper({@required this.holeRadius});

  final double holeRadius;

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height / 2 - holeRadius / 2)
      ..arcToPoint(
        Offset(size.width, size.height / 2 + holeRadius / 2),
        clockwise: false,
        radius: Radius.circular(1),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..lineTo(0.0, size.height / 2 + holeRadius / 2)
      ..arcToPoint(
        Offset(0.0, size.height / 2 - holeRadius / 2),
        clockwise: false,
        radius: Radius.circular(1),
      );

    path.lineTo(0.0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(DolDurmaClipper oldClipper) => true;
}
