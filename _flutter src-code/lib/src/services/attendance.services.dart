import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/services/DTO/add_attendance.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/http.services.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  static const String _baseUrl = "https://localhost:7170/api";

  static Future<http.Response> getRemarksCount(
      {int? studentNo, DateTime? date}) async {
    Map<String, String>? query;
    if (studentNo != null && date != null) {
      query = {
        'studentNo': studentNo.toString(),
        'date': date.toIso8601String()
      };
    } else if (studentNo != null) {
      query = {'studentNo': studentNo.toString()};
    }
    return await HttpService.get("$_baseUrl/GetRemarksCount", query: query);
  }

  static Future<CRUDReturn> getAll({
    DateTime? date,
    String? room,
    int? studentNo,
    Remarks? remarks,
  }) async {
    try {
      Map<String, dynamic>? query = {};
      // if (date != null) query['date'] = date;
      if (room != null) query['room'] = room;
      if (studentNo != null) query['studentNo'] = studentNo.toString();
      if (remarks != null) query['remarks'] = remarks;
      print("ndanceService getAll 1 $query");
      final response =
          await HttpService.get('$_baseUrl/Attendance', query: query);
      print("AttendanceService getAll 2 ${response.body}");
      if (response.statusCode == 200) {
        if (response.body.isNotEmpty) {
          if (kDebugMode) Logger().i('${response.statusCode} ${response.body}');
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
    } catch (e, stactrace) {
      if (kDebugMode) print('AttendanceService getAll $e $stactrace');
      rethrow;
    }
  }

  static Future<http.Response> getAllSA({required int studentId}) async {
    return await HttpService.get("$_baseUrl/GetAllSA",
        query: {'studentId': studentId.toString()});
  }

  static Future<http.Response> getAllFA({required int facultyId}) async {
    return await HttpService.get("$_baseUrl/GetAllFA",
        query: {'facultyId': facultyId.toString()});
  }

  static Future<http.Response> addAttendance(
      AddAttendanceDto attendance) async {
    return await HttpService.post(_baseUrl, body: attendance);
  }
}
