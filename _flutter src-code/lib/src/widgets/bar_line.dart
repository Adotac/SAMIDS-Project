import 'package:flutter/material.dart';

class BarLine extends StatelessWidget {
  final int max;
  final int current;
  final String subject;
  const BarLine({
    Key? key,
    required this.max,
    required this.current,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            color: Colors.grey.shade400,
            height: 200 / max * current,
            width: 65,
            // ignore: prefer_const_constructors
            child: Text(
              // "$current/$max",
              "$current",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // ignore: prefer_const_constructors
          Container(
            width: 65,
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              subject,
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                fontSize: 10,
                letterSpacing: -.1,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Container(
          //   width: 65,
          //   padding: const EdgeInsets.only(top: 8.0),
          //   child: const Text(
          //     "10:30-11:30",
          //     style: TextStyle(
          //       overflow: TextOverflow.ellipsis,
          //       fontSize: 10,
          //       letterSpacing: -.1,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
