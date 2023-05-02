import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';
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

      // Set headers
      request.headers.addAll({
        'accept': 'text/plain',
        'Content-Type': 'multipart/form-data',
      });

      // Create a multipart file from the selected file
      var reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        reader.result as List<int>,
        filename: file.name,
        contentType: MediaType('text', 'csv'),
      );

      // Add the multipart file to the request
      request.files.add(multipartFile);

      // Send the request
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

  static Future<CRUDReturn> postCsvFile(String apiUrl, html.File file) async {
    try {
      var url = Uri.parse('$_baseUrl/CSV/$apiUrl');
      var request = http.MultipartRequest('POST', url);

      // Set headers
      request.headers.addAll({
        'accept': 'text/plain',
        'Content-Type': 'multipart/form-data',
      });

      // Create a multipart file from the selected file
      var reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        reader.result as List<int>,
        filename: file.name,
        contentType: MediaType('text', 'csv'),
      );

      // Add the multipart file to the request
      request.files.add(multipartFile);

      // Send the request
      var response = await request.send();
      final http.Response httpResponse =
          await http.Response.fromStream(response);

      if (kDebugMode) {
        _logger
            .i('postCsvFile ${httpResponse.statusCode} ${httpResponse.body}');
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
      if (kDebugMode) print('ConfigService postCsvFile $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> addSecurity(
      String id, String securityQuestion, String securityAnswer) async {
    try {
      print([id, securityQuestion, securityAnswer]);
      final response = await HttpService.post(
        '$_baseUrl/Auth/add-security?id=$id',
        body: {
          "securityQuestion": securityQuestion,
          "securityAnswer": securityAnswer,
        },
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        _logger.i('addSecurity ${response.statusCode} ${response.body}');
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
      if (kDebugMode) print('ConfigService addSecurity $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> forgotPassword(
      String email, String securityQuestion, String securityAnswer) async {
    try {
      final response = await HttpService.post(
        '$_baseUrl/Auth/forgot-password',
        body: jsonEncode({
          "email": email,
          "securityQuestion": securityQuestion,
          "securityAnswer": securityAnswer,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        _logger.i('forgotPassword ${response.statusCode} ${response.body}');
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
      if (kDebugMode) print('ConfigService forgotPassword $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> getSubjects() async {
    try {
      final response = await HttpService.get('$_baseUrl/Subject');
      if (kDebugMode) {
        _logger.i('getSubjects ${response.statusCode} ${response.body}');
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
      if (kDebugMode) print('ConfigService getSubjects $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> updateStudent({
    required int studentNo,
    required String lastName,
    required String firstName,
    required String course,
    required int year,
  }) async {
    try {
      final response = await HttpService.patch(
        '$_baseUrl/Student',
        body: jsonEncode({
          'studentNo': studentNo,
          'lastName': lastName,
          'firstName': firstName,
          'course': course,
          'year': year,
        }),
        headers: {"Content-Type": "application/json"},
      );

      if (kDebugMode) {
        _logger.i('StudentService ${response.statusCode} ${response.body}');
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
      if (kDebugMode) print('StudentService updateStudent $e $stacktrace');
      rethrow;
    }
  }
}
