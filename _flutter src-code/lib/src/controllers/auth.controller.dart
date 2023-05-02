import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/login_user.dart';
import 'package:samids_web_app/src/services/DTO/register_user.dart';
import 'package:samids_web_app/src/services/auth.services.dart';

class AuthController with ChangeNotifier {
  bool isLoggedIn = false;
  User? loggedInUser;
  final Logger _logger = Logger();
  static void initialize() =>
      GetIt.instance.registerSingleton<AuthController>(AuthController());

  static AuthController get I => GetIt.instance<AuthController>();
  static AuthController get instance => GetIt.instance<AuthController>();

  void setLoginToFalse() {
    isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      var credentials =
          UserDto.fromJson({'Username': username, 'Password': password});
      CRUDReturn result = await AuthService.login(credentials);

      if (result.success) {
        isLoggedIn = true;
        if (kDebugMode) {
          _logger.i(' AuthController logins ${result.data['user']}');
        }
        loggedInUser = User.fromJson(result.data['user']);
        notifyListeners();
        return true;
      } else {
        throw result.data;
      }
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' AuthController logins $e $stacktrace');
      rethrow;
    }
  }

  Future<void> changePassword(
      String password, int userNo, String userType) async {
    try {
      final result =
          await AuthService.changePassword(password, userNo, userType);

      if (result.success) {
        // handle success
      } else {
        throw result.data;
      }
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' changePassword $e $stacktrace');
      rethrow;
    }
  }

  Future<bool> register(
      int userId, String email, String password, int type) async {
    try {
      Map<String, dynamic> credentials = {
        'idNo': userId,
        'email': email,
        'password': password,
        'type': type
      };
      print(credentials);
      CRUDReturn result = await AuthService.register(credentials);

      if (result.success) {
        notifyListeners();
        return true;
      } else {
        throw result.data;
      }
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  void logout() {
    isLoggedIn = false;
    loggedInUser = null;
    notifyListeners();
  }
}
