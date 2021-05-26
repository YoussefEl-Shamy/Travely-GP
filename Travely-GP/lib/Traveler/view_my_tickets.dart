import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travely/Traveler/ticket_item.dart';

class ViewTickets extends StatefulWidget {
  @override
  _ViewTicketsState createState() => _ViewTicketsState();
}

class _ViewTicketsState extends State<ViewTickets> {
  var userId = FirebaseAuth.instance.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(0.0, 0.0),
        child: Container(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 20.0, bottom: 25.0),
              child: Row(
                children: [
                  InkWell(
                    child: Icon(Icons.arrow_back),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 25),
                  Text(
                    "My Tickets",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("travelersPackages")
                      .where("travelerId", isEqualTo: userId)
                      .snapshots(),
                  builder: (ctx, snapShot) {
                    if (snapShot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var docs = snapShot.data.docs;
                    return ListView.builder(
                      itemBuilder: (ctx, index) {
                        return Ticket(
                          ticketId: docs[index]['ticketId'],
                          packageId: docs[index]['packageId'],
                          organizerId: docs[index]['organizerId'],
                          ticketsNum: docs[index]['numOfTickets'],
                        );
                      },
                      itemCount: docs.length,
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
