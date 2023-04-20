import 'package:flutter/material.dart';

class DataNumber extends StatelessWidget {
  final String number;
  final String description;
  const DataNumber(
      {super.key, required this.number, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      // width: 80,
      alignment: Alignment.centerLeft,
      // padding: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(description),
        ],
      ),
    );
  }
}
