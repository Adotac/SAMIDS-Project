import 'dart:convert';
import 'dart:html';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';

import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/faculty_model.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:samids_web_app/src/model/subject_model.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';

import '../services/student.services.dart';

class FacultyController with ChangeNotifier {
  final Student student;
  List<Attendance> attendance = [];
  List<Attendance> allAttendanceList = [];
  List<SubjectSchedule> studentClasses = [];

  double onTimeCount = 0;
  double lateCount = 0;
  double absentCount = 0;
  double cuttingCount = 0;

  bool isStudentClassesCollected = false;
  bool isCountCalculated = false;
  bool isAttendanceTodayCollected = false;
  bool isAllAttendanceCollected = false;

  FacultyController({required this.student});

  static void initialize() {}

  static FacultyController get I => GetIt.instance<FacultyController>();
  static FacultyController get instance => GetIt.instance<FacultyController>();
  logout() {
    isStudentClassesCollected = false;
    isCountCalculated = false;
    isAttendanceTodayCollected = false;
    isAllAttendanceCollected = false;

    onTimeCount = 0;
    lateCount = 0;
    absentCount = 0;
    cuttingCount = 0;

    attendance.clear();
    allAttendanceList.clear();
    studentClasses.clear();
  }

  handEventJsonAttendance(CRUDReturn result) {
    if (attendance.isNotEmpty) attendance.clear();
    for (Map<String, dynamic> map in result.data) {
      attendance.add(Attendance.fromJson(map));
    }

    isAttendanceTodayCollected = true;
    notifyListeners();
  }

  handEventJsonAttendanceAll(CRUDReturn result) {
    if (allAttendanceList.isNotEmpty) allAttendanceList.clear();

    for (Map<String, dynamic> map in result.data) {
      allAttendanceList.add(Attendance.fromJson(map));
    }

    notifyListeners();
  }

  Future<void> getAttendanceToday() async {
    try {
      if (isAttendanceTodayCollected) return;
      CRUDReturn response = await AttendanceService.getAll(
          studentNo: student.studentNo, date: DateTime(2023));
      if (response.success) {
        handEventJsonAttendance(response);
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendanceNow $e $stacktrace');
    }
  }

  Future<void> getStudentClasses() async {
    try {
      if (isStudentClassesCollected) return;
      CRUDReturn response =
          await StudentService.getStudentClasses(student.studentNo);
      if (response.success) {
        handleEventJsonStudentClasses(response);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('StudentDashboardController getStudentClasses $e $stacktrace');
    }
  }

  void handleEventJsonStudentClasses(CRUDReturn result) {
    if (studentClasses.isNotEmpty) studentClasses.clear();
    for (Map<String, dynamic> map in result.data) {
      studentClasses.add(SubjectSchedule.fromJson(map));
    }

    isStudentClassesCollected = true;
    notifyListeners();
  }

  Future<void> getAttendanceAll() async {
    try {
      if (isAllAttendanceCollected) return;
      CRUDReturn response = await AttendanceService.getAll(
        studentNo: student.studentNo,
      );

      if (response.success) {
        await handEventJsonAttendanceAll(response);
        getRemarksCount();
        isAllAttendanceCollected = true;
        notifyListeners();
      }
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendanceAll $e $stacktrace');
    }
  }

  String formatTime(DateTime dateTime) {
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
    return formattedTime;
  }

  String formatDate(DateTime dateTime) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    return formattedDate;
  }

  Color getStatusColor(Remarks remarks, BuildContext context) {
    switch (remarks) {
      case Remarks.onTime:
        return Colors.green; // Modify with the desired color for onTime
      case Remarks.late:
        return Colors.orange; // Modify with the desired color for late
      case Remarks.cutting:
        return Colors
            .yellow.shade700; // Modify with the desired color for cutting
      case Remarks.absent:
        return Colors.red
            .withOpacity(0.5); // Modify with the desired color for absent
    }
  }

  Text getStatusText(String status) {
    final String lowercaseStatus = status.toLowerCase();
    Color color;
    String text = '';
    switch (lowercaseStatus) {
      case 'absent':
        color = Colors.red;
        text = 'Absent';
        break;
      case 'cutting':
        color = Colors.yellow.shade700;
        text = 'Cutting';
        break;
      case 'ontime':
        color = Colors.green;
        text = 'On Time';
        break;
      case 'late':
        color = Colors.orange;
        text = 'Late';
        break;
      default:
        color = Colors.black;
        text = 'Unknown';
        break;
    }
    return Text(
      text,
      style: TextStyle(color: color),
    );
  }

  void getRemarksCount() {
    try {
      if (isCountCalculated) return;
      for (Attendance attendance in allAttendanceList) {
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
