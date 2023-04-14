import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';

class StudentDashboardController with ChangeNotifier {
  final Student student;
  List<Attendance> attendance = [];
  List<Attendance> allAttendance = [];

  double onTimeCount = 0;
  double lateCount = 0;
  double absentCount = 0;
  double cuttingCount = 0;
  bool isCountCalculated = false;

  StudentDashboardController({required this.student});

  static void initialize(Student student) {
    GetIt.instance.registerSingleton<StudentDashboardController>(
        StudentDashboardController(student: student));
  }

  static StudentDashboardController get I =>
      GetIt.instance<StudentDashboardController>();
  static StudentDashboardController get instance =>
      GetIt.instance<StudentDashboardController>();

  handEventJsonAttendance(CRUDReturn result) {
    if (attendance.isNotEmpty) attendance.clear();
    for (Map<String, dynamic> map in result.data) {
      attendance.add(Attendance.fromJson(map));
    }
    notifyListeners();
  }

  handEventJsonAttendanceAll(CRUDReturn result) {
    if (allAttendance.isNotEmpty) allAttendance.clear();

    for (Map<String, dynamic> map in result.data) {
      allAttendance.add(Attendance.fromJson(map));
    }

    notifyListeners();
  }

  Future<void> getAttendanceToday() async {
    try {
      CRUDReturn response = await AttendanceService.getAll(
          studentNo: student.studentNo, date: DateTime(2023));
      //create loop 1 to 5000
      //create loop 1 to 5000

      if (response.success) {
        handEventJsonAttendance(response);
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendanceNow $e $stacktrace');
    }
  }

  Future<void> getAttendanceAll() async {
    try {
      CRUDReturn response = await AttendanceService.getAll(
        studentNo: student.studentNo,
      );

      if (response.success) {
        await handEventJsonAttendanceAll(response);
        getRemarksCount();
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendanceAll $e $stacktrace');
    }
  }

  String formatTime(DateTime dateTime) {
    final time = TimeOfDay.fromDateTime(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }

  void getRemarksCount() {
    try {
      if (isCountCalculated) return;
      for (Attendance attendance in allAttendance) {
        if (attendance.remarks == Remarks.late) lateCount += 1;
        if (attendance.remarks == Remarks.onTime) onTimeCount += 1;
        if (attendance.remarks == Remarks.absent) absentCount += 1;
        if (attendance.remarks == Remarks.cutting) cuttingCount += 1;
        isCountCalculated = true;
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('getRemarksCount $e $stacktrace');
    }
  }
}
