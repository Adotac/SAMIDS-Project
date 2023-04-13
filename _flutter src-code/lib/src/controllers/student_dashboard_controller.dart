import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/src/response.dart';
import 'package:samids_web_app/src/controllers/student.controller.dart';
import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';

import '../model/student_model.dart';

class StudentDashboardController with ChangeNotifier {
  final Student student;
  final AttendanceService _attendanceService = AttendanceService();
  StudentDashboardController({required this.student});

  static void initialize(Student student) {
    GetIt.instance.registerSingleton<StudentDashboardController>(
        StudentDashboardController(student: student));
  }

  static StudentDashboardController get I =>
      GetIt.instance<StudentDashboardController>();
  static StudentDashboardController get instance =>
      GetIt.instance<StudentDashboardController>();

  Future<List<Attendance>> getAttendance() async {
    try {
      Response response = await _attendanceService.getAll(
          studentNo: student.studentNo, date: DateTime.now());
      if (response.statusCode == 200) {
        for (var i = 0; i < response.body.length; i++) {
          print(response.body[i]);
        }

        // List<Attendance> attendance = Attendance.fromJson(response.body);
        return [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
