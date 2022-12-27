import 'package:flutter/material.dart';

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
