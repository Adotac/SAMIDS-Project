import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;

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

  static Future<CRUDReturn> addStudentFromCSV(html.File file) async {
    try {
      var url = Uri.parse('$_baseUrl/CSV/csvStudent');
      var request = http.MultipartRequest('POST', url);

      var reader = html.FileReader();
      var completer = Completer<List<int>>();
      reader.onLoadEnd.listen((event) {
        completer.complete(reader.result as List<int>);
      });
      reader.readAsArrayBuffer(file);

      List<int> fileBytes = await completer.future;
      var fileStream = http.ByteStream(Stream.fromIterable([fileBytes]));

      var multipartFile = http.MultipartFile('filePath', fileStream, file.size,
          filename: file.name);
      request.files.add(multipartFile);

      var response = await request.send();
      final http.Response httpResponse =
          await http.Response.fromStream(response);

      if (kDebugMode) {
        _logger.i(
            'addStudentFromCSV ${httpResponse.statusCode} ${httpResponse.body}');
      }

      if (httpResponse.statusCode == 200) {
        if (httpResponse.body.isNotEmpty) {
          final jsonResponse = jsonDecode(httpResponse.body);
          return CRUDReturn.fromJson(jsonResponse);
        } else {
          throw Exception("Empty response body");
        }
      } else {
        String errorMessage = "Something went wrong.";
        if (httpResponse.body.isNotEmpty) {
          final jsonResponse = jsonDecode(httpResponse.body);
          errorMessage = jsonResponse['message'] ?? "Something went wrong.";
        }
        throw Exception(
            "Request failed with status: ${httpResponse.statusCode}. Error message: $errorMessage");
      }
    } catch (e, stacktrace) {
      if (kDebugMode) print('ConfigService addStudentFromCSV $e $stacktrace');
      rethrow;
    }
  }
}
