import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/controllers/student.controller.dart';
import 'package:samids_web_app/src/model/attendance_model.dart';
import 'package:samids_web_app/src/model/user_model.dart';
import 'package:samids_web_app/src/services/attendance.services.dart';

class StudentDashboardController with ChangeNotifier {
  final Student student;
  
  StudentDashboardController({required this.student});

  static void initialize(Student student) {
    GetIt.instance.registerSingleton<StudentDashboardController>(StudentDashboardController(student: student));
  }

  StudentDashboardController get I => GetIt.instance<StudentDashboardController>();
  StudentDashboardController get instance => GetIt.instance<StudentDashboardController>();

  Future<void> getAttendances(DateTime? date, String? room, Remarks? remarks)async{
    return await AttendanceService.getAll(studentNo: user.)
  }
}