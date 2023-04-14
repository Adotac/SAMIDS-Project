import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';

import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';

class StudentDashboardController with ChangeNotifier {
  final Student student;
  List<Attendance> attendance = [];
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
      CRUDReturn response = await AttendanceService.getAll(
          studentNo: student.studentNo, date: DateTime.now());

      if (response.success) {
        if (attendance.isNotEmpty) attendance.clear();

        for (Map<String, dynamic> map in response.data) {
          print(map);
          attendance.add(Attendance.fromJson(map));
        }
        print(attendance);
        // List<Attendance> attendance = Attendance.fromJson(response.body);
        return attendance;
      } else {
        return [];
      }
    } catch (e, stacktrace) {
      print('StudentDashboardController getAttendance $e $stacktrace');
      return [];
    }
  }
}
