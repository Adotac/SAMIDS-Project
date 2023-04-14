import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/login_user.dart';
import 'package:samids_web_app/src/services/DTO/register_user.dart';

import 'package:samids_web_app/src/services/http.services.dart';

class AuthService {
  static const String _baseUrl = 'https://localhost:7170/api/Auth';
  final Logger _logger = Logger();

  static Future<CRUDReturn> login(UserDto credentials) async {
    try {
      print(credentials.toJson());
      final response = await HttpService.post('$_baseUrl/login',
          body: credentials.toJson(),
          headers: {"Content-Type": "application/json"});
      print('jsonResponse');
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      return CRUDReturn.fromJson(jsonResponse);
    } catch (e, stacktrace) {
      if (kDebugMode) print('AuthService login $e $stacktrace');
      return CRUDReturn(success: false, data: e);
    }
  }

  static Future<CRUDReturn> register(UserRegisterDto credentials) async {
    final response = await HttpService.post('$_baseUrl/register',
        body: credentials.toJson());
    final jsonResponse = jsonDecode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> changePassword(
      String newPassword, User user) async {
    final response =
        await HttpService.patch('$_baseUrl/change-password', body: {
      'newPassword': newPassword,
      'user': user.toJson(),
    });
    final jsonResponse = jsonDecode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }
}
