import 'package:flutter/material.dart';

class AuthViewController with ChangeNotifier {
  bool showRegister = false;

  setShowRegister(bool value) {
    showRegister = value;
    notifyListeners();
  }
}
