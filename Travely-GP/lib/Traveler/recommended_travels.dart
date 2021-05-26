import 'package:flutter/material.dart';

class RecommendedTarvels extends StatefulWidget {
  @override
  _RecommendedTarvelsState createState() => _RecommendedTarvelsState();
}

class _RecommendedTarvelsState extends State<RecommendedTarvels> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Scaffold(
        body: Center(
          child: Text("No Recommendation till you rate the travels you took"),
        ),
      ),
    );
  }
}
