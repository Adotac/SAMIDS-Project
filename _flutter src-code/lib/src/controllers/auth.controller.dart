import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/login_user.dart';
import 'package:samids_web_app/src/services/DTO/register_user.dart';
import 'package:samids_web_app/src/services/auth.services.dart';


class AuthController with ChangeNotifier {
  bool isLoggedIn = false;
  User? loggedInUser;

  static void initialize() =>
      GetIt.instance.registerSingleton<AuthController>(AuthController());

  static AuthController get I => GetIt.instance<AuthController>();
  static AuthController get instance => GetIt.instance<AuthController>();

  Future<bool> login(String username, String password) async {
    try {
      print("Im here now");
      var credentials = UserDto.fromJson({'Username':username,'Password':password}); 
      CRUDReturn result = await AuthService.login(credentials);
      if (result.success) {
        isLoggedIn = true;
        loggedInUser = User.fromJson(result.data['user']);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e,st) {
      print("$e and $st"); 
      return false;
    }
  }

  Future<bool> register(UserRegisterDto credentials) async {
    try {
      CRUDReturn result = await AuthService.register(credentials);
      if (result.success) {
        isLoggedIn = true;
        loggedInUser = User.fromJson(jsonDecode(result.data));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> changePassword(String newPassword, User user) async {
    try {
      CRUDReturn result = await AuthService.changePassword(newPassword, user);
      if (result.success) {
        // Update user object
        loggedInUser = User.fromJson(jsonDecode(result.data));
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void logout() {
    isLoggedIn = false;
    loggedInUser = null;
    notifyListeners();
  }
}