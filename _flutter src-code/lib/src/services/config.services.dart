import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:samids_web_app/src/model/config_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/http.services.dart';
import 'package:http/http.dart' as http;

class ConfigService {
  static const String _baseUrl = "https://localhost:7170/api";
  static final Logger _logger = Logger();

  static Future<CRUDReturn> getConfig() async {
    try {
      final response = await HttpService.get('$_baseUrl/Config');
      if (kDebugMode) {
        _logger
            .i('getFacultiesClasses ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          return CRUDReturn.fromJson(jsonResponse);
        } else {
          throw Exception("Empty response body");
        }
      } else {
        String errorMessage = "Something went wrong.";
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          errorMessage = jsonResponse['message'] ?? "Something went wrong.";
        }
        throw Exception(
            "Request failed with status: ${response.statusCode}. Error message: $errorMessage");
      }
    } catch (e, stacktrace) {
      if (kDebugMode) print('ConfigService getConfig $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> updateConfig(Config config) async {
    try {
      final response = await HttpService.post(
        '$_baseUrl/Config',
        body: config.toJson(),
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        _logger.i('ConfigService ${response.statusCode} ${response.body}');
      }
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          return CRUDReturn.fromJson(jsonResponse);
        } else {
          throw Exception("Empty response body");
        }
      } else {
        String errorMessage = "Something went wrong.";
        if (response.body.isNotEmpty) {
          final jsonResponse = jsonDecode(response.body);
          errorMessage = jsonResponse['message'] ?? "Something went wrong.";
        }
        throw Exception(
            "Request failed with status: ${response.statusCode}. Error message: $errorMessage");
      }
    } catch (e, stacktrace) {
      if (kDebugMode) print('ConfigService updateConfig $e $stacktrace');
      rethrow;
    }
  }
}
