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
      if (kDebugMode) {
        _logger.i('getFaculties ${response.statusCode} ${response.body}');
      }
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' getFaculties $e $stacktrace');
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

  static Future<void> updateFaculty(
      int facultyNo, String firstName, String lastName) async {
    try {
      final body = {
        'facultyNo': facultyNo,
        'firstName': firstName,
        'lastName': lastName,
      };

      // Add a print statement to check the payload
      print('Payload: $body');

      final response = await HttpService.patch(
        '$_baseUrl/Faculty',
        headers: {
          'accept': 'text/plain',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      if (kDebugMode) {
        _logger.i('updateFaculty ${response.statusCode} ${response.body}');
      }
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' updateFaculty $e $stacktrace');
      rethrow;
    }
  }

  static Future<CRUDReturn> getFacultyById(int id) async {
    final response = await HttpService.get('$_baseUrl/Faculty/$id');
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> addFaculty(AddFacultyDto faculty) async {
    final body = json.encode(faculty.toJson());
    final response = await HttpService.post('$_baseUrl/Faculty', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
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

  static Future<CRUDReturn> addFacultySubjects(
      FacultySubjectDto<dynamic> request) async {
    final body = json.encode(request.toJson());
    final response =
        await HttpService.patch('$_baseUrl/Faculty/AddSubjects', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }
}
