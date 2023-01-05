import 'package:flutter/material.dart';

import '../widgets/bar_line.dart';

String getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Dashboard';
    case 1:
      return 'Attendance';
    case 2:
      return 'Classes';
    case 3:
      return 'Accounts';
    case 4:
      return 'Configurations';
    default:
      return 'Not found page';
  }
}

const primaryColor = Color(0xFF685BFF);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const black = Colors.black;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: black.withOpacity(0.3), height: 1);

List<Widget> barLineSampleData = [
  // Container(height: 200, width: 65, color: Colors.grey),
  // Container(height: 20, width: 65, color: Colors.grey),
  // Padding(
  //   padding: const EdgeInsets.all(8.0),
  //   child: Container(height: 100, width: 65, color: Colors.grey),
  // ),
  // Container(
  //   height: 10,
  //   width: 65,
  //   color: Colors.pink,
  //   child: Text("hi"),
  // ),
  // Container(height: 200, width: 65, color: Colors.grey),
  // Padding(
  //   padding: const EdgeInsets.all(8.0),
  //   child: Container(height: 150, width: 65, color: Colors.grey),
  // ),
  // Container(height: 200, width: 65, color: Colors.grey),

  BarLine(max: 8, current: 5, subject: "Prog - 10023"),
  BarLine(max: 9, current: 7, subject: "Prog2 - 2423"),
  BarLine(max: 11, current: 9, subject: "DataStruct - 1234 sdadsdasdsad"),
  BarLine(max: 8, current: 2, subject: "AppsDev - 3124"),
  BarLine(max: 15, current: 10, subject: "QM - 9321"),
  BarLine(max: 5, current: 3, subject: "Algo - 1032"),
  BarLine(max: 15, current: 6, subject: "Digital -10234"),
  BarLine(max: 12, current: 4, subject: "IM - 2321"),
  BarLine(max: 8, current: 5, subject: "Prog - 10023"),
  BarLine(max: 9, current: 7, subject: "Prog2 - 2423"),
  BarLine(max: 11, current: 9, subject: "DataStruct - 1234 sdadsdasdsad"),
  BarLine(max: 8, current: 2, subject: "AppsDev - 3124"),
  BarLine(max: 15, current: 10, subject: "QM - 9321"),
  BarLine(max: 5, current: 3, subject: "Algo - 1032"),
  BarLine(max: 15, current: 6, subject: "Digital -10234"),
  BarLine(max: 12, current: 4, subject: "IM - 2321"),
  BarLine(max: 8, current: 5, subject: "Prog - 10023"),
  BarLine(max: 9, current: 7, subject: "Prog2 - 2423"),
  BarLine(max: 11, current: 9, subject: "DataStruct - 1234 sdadsdasdsad"),
  BarLine(max: 8, current: 2, subject: "AppsDev - 3124"),
  BarLine(max: 15, current: 10, subject: "QM - 9321"),
  BarLine(max: 5, current: 3, subject: "Algo - 1032"),
  BarLine(max: 15, current: 6, subject: "Digital -10234"),
  BarLine(max: 12, current: 4, subject: "IM - 2321"),
];
