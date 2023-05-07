import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:samids_web_app/src/services/DTO/add_faculty.dart';
import 'package:samids_web_app/src/services/DTO/add_facultySubject.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/update_faculty.dart';
import 'package:samids_web_app/src/services/http.services.dart';

class FacultyService {
  static const String _baseUrl = "https://localhost:7170/api";
  static final Logger _logger = Logger();

  static Future<CRUDReturn> getFaculties() async {
    try {
      final response = await HttpService.get('$_baseUrl/Faculty');
      // if (kDebugMode) {
      //   _logger.i('getFaculties ${response.statusCode} ${response.body}');
      // }
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' getFaculties $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> createFaculty(
      int facultyNo, String lastName, String firstName) async {
    try {
      final body = {
        'facultyNo': facultyNo,
        'lastName': lastName,
        'firstName': firstName,
      };
      final jsonBody = json.encode(body);

      final response = await HttpService.post(
        '$_baseUrl/Faculty',
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (kDebugMode) {
        _logger.i('createFaculty ${response.statusCode} ${response.body}');
      }

      final jsonResponse = json.decode(response.body);
      return CRUDReturn.fromJson(jsonResponse);
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' createFaculty $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> getFacultyClasses(int id) async {
    try {
      final response =
          await HttpService.get('$_baseUrl/Faculty/classes/?facultyNo=$id');
      if (kDebugMode) {
        _logger
            .i('getFacultiesClasses ${response.statusCode} ${response.body}');
      }
      final jsonResponse = json.decode(response.body);
      return CRUDReturn.fromJson(jsonResponse);
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' getFacultiesClasses $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> addFaculty(
      int facultyNo, String lastName, String firstName) async {
    try {
      final body = {
        'facultyNo': facultyNo,
        'lastName': lastName,
        'firstName': firstName,
      };
      print('addFaculty Payload: $body');

      final response = await HttpService.post(
        '$_baseUrl/Faculty',
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (kDebugMode) {
        _logger.i('createFaculty ${response.statusCode} ${response.body}');
      }

      final jsonResponse = json.decode(response.body);
      return CRUDReturn.fromJson(jsonResponse);
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' createFaculty $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> getFacultyById(int id) async {
    try {
      final response =
          await HttpService.get('$_baseUrl/Faculty?id=$id', headers: {
        'accept': 'application/json',
      });
      if (kDebugMode) {
        _logger.i('getFacultyById ${response.statusCode} ${response.body}');
      }
      final jsonResponse = json.decode(response.body);
      return CRUDReturn.fromJson(jsonResponse);
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' getFacultyById $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> deleteFaculty(int id) async {
    final response = await HttpService.delete('$_baseUrl/Faculty?id=$id');
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> removeFacultySubjects(
      FacultySubjectDto<dynamic> request) async {
    final body = json.encode(request.toJson());
    final response =
        await HttpService.patch('$_baseUrl/Faculty/RemoveSubjects', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> addFacultySubject(
      int facultyNo, int subjectId) async {
    try {
      // Add a print statement to check the payload
      final body = {
        'facultyNo': facultyNo,
        'subject': subjectId,
      };

      print('Payload: $body');

      final response = await HttpService.patch(
        '$_baseUrl/Faculty/AddSubject',
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (kDebugMode) {
        _logger.i('addFacultySubject ${response.statusCode} ${response.body}');
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
      if (kDebugMode) _logger.i(' addFacultySubject $e $stacktrace');
      rethrow;
    }
  }
}
