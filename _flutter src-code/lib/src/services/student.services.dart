import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/model/subject_model.dart';
import 'package:samids_web_app/src/services/DTO/add_student.dart';
import 'package:samids_web_app/src/services/DTO/add_studentsubject.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/update_student.dart';
import 'package:samids_web_app/src/services/helper.services.dart';
import 'package:samids_web_app/src/services/http.services.dart';
import 'package:logger/logger.dart';

class StudentService {
  final Logger _logger = Logger();

  static const String _baseUrl = "https://localhost:7170/api";

  static Future<CRUDReturn> getStudents() async {
    final response = await HttpService.get('$_baseUrl/students');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> getStudentById(int id) async {
    try {
      final response = await HttpService.get('$_baseUrl/students/byId/$id');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' getStudentById $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> getStudentByRfid(int rfid) async {
    try {
      final response = await HttpService.get('$_baseUrl/students/byRfid/$rfid');
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' getStudentByRfid $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> addStudent(AddStudentDto student) async {
    try {
      final response =
          await HttpService.post('$_baseUrl/students', body: student.toJson());
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' addStudent $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> deleteStudent(int id) async {
    try {
      final response = await HttpService.delete('$_baseUrl/students?id=$id');
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' deleteStudent $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> updateStudent(StudentUpdateDto student) async {
    try {
      final response =
          await HttpService.patch('$_baseUrl/students', body: student.toJson());
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' updateStudent $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> addStudentSubject(
      AddStudentSubjectDto<int> request) async {
    try {
      final response = await HttpService.patch('$_baseUrl/students/addSubject',
          body: request.toJson());
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' addStudentSubject $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> addStudentSubjects(
      AddStudentSubjectDto<List<Subject>> request) async {
    try {
      final response = await HttpService.patch('$_baseUrl/students/addSubjects',
          body: request.toJson());
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' addStudentSubjects $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> removeStudentSubject(
      AddStudentSubjectDto<int> request) async {
    try {
      final response = await HttpService.patch(
          '$_baseUrl/students/removeSubject',
          body: request.toJson());
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i(' removeStudentSubject $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> removeStudentSubjects(
      AddStudentSubjectDto<List<Subject>> request) async {
    try {
      final response = await HttpService.patch(
          '$_baseUrl/students/removeSubjects',
          body: request.toJson());
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i('removeStudentSubjects $e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> getStudentClasses(DateTime date, int studentNo) async {
    try {
      final response = await HttpService.get(
          '$_baseUrl/students/classesByDate?date=$date&studentNo=$studentNo');
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');
      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i('$e $stacktrace');
      rethrow;
    }
  }

  Future<CRUDReturn> getStudentClassesByDay(
      DateTime date, int studentNo) async {
    try {
      final response = await HttpService.get('$_baseUrl/students/classesByDay',
          query: {'date': '${toDateOnly(date)}', 'studentNo': '$studentNo'});
      if (kDebugMode) _logger.i('${response.statusCode} ${response.body}');

      return CRUDReturn.fromJson(jsonDecode(response.body));
    } catch (e, stacktrace) {
      if (kDebugMode) _logger.i('getStudentClassesByDay $e $stacktrace');
      rethrow;
    }
  }
}
