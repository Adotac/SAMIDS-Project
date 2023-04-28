//faculty
//75779

import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:samids_web_app/src/model/attendance_model.dart';

import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';
import '../model/config_model.dart';
import '../model/faculty_model.dart';
import '../services/config.services.dart';
import '../services/faculty.services.dart';
import '../services/student.services.dart';

class FacultyController with ChangeNotifier {
  final Faculty faculty;
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

  FacultyController({required this.faculty});

  static void initialize(Faculty faculty) {
    GetIt.instance.registerSingleton<FacultyController>(
        FacultyController(faculty: faculty));
  }

  static FacultyController get I => GetIt.instance<FacultyController>();
  static FacultyController get instance => GetIt.instance<FacultyController>();

  Config? config;

  void handleEventJsonConfig(CRUDReturn result) {
    try {
      if (result.data.isNotEmpty) {
        config = Config.fromJson(result.data);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonConfig $e $stacktrace');
    }
  }

  Future<void> getConfig() async {
    try {
      CRUDReturn response = await ConfigService.getConfig();
      if (response.success) {
        handleEventJsonConfig(response);
      }
    } catch (e, stacktrace) {
      print('ConfigController getConfig $e $stacktrace');
    }
  }

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

  // Future<void> getStudentClasses() async {
  //   try {
  //     if (isStudentClassesCollected) return;
  //     CRUDReturn response =
  //         await StudentService.getStudentClasses(faculty.facultyNo);
  //     if (response.success) {
  //       handleEventJsonStudentClasses(response);
  //     }
  //     notifyListeners();
  //   } catch (e, stacktrace) {
  //     print('StudentDashboardController getStudentClasses $e $stacktrace');
  //   }
  // }

  void handleEventJsonStudentClasses(CRUDReturn result) {
    try {
      if (studentClasses.isNotEmpty) studentClasses.clear();
      for (Map<String, dynamic> map in result.data) {
        studentClasses.add(SubjectSchedule.fromJson(map));
      }

      isStudentClassesCollected = true;
      notifyListeners();
    } catch (e, stacktrace) {
      print('handleEventJsonStudentClasses $e $stacktrace');
    }
  }

  //create function to query to FacultyService getFacultyClasses
  Future<void> getFacultyClasses() async {
    try {
      if (isStudentClassesCollected) return;
      CRUDReturn response =
          await FacultyService.getFacultyClasses(faculty.facultyNo);
      if (response.success) {
        handleEventJsonStudentClasses(response);
      }
      notifyListeners();
    } catch (e, stacktrace) {
      print('StudentDashboardController getStudentClasses $e $stacktrace');
    }
  }

  Future<void> getAttendanceAll(String? date) async {
    try {
      if (isAllAttendanceCollected) return;
      CRUDReturn response = date != null
          ? await AttendanceService.getAll(
              studentNo: faculty.facultyNo,
              date: date,
            )
          : await AttendanceService.getAll(
              // studentNo: faculty.facultyNo,
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

  void filterAttendance(String query) {}
}
