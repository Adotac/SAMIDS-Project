import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:samids_web_app/src/controllers/student.controller.dart';

class StudentDashboardController with ChangeNotifier {
  final int studentNo;
  
  StudentDashboardController({required this.studentNo});

  static void initialize(int studentNo) {
    GetIt.instance.registerSingleton<StudentDashboardController>(StudentDashboardController(studentNo: studentNo));
  }

  StudentDashboardController get I => GetIt.instance<StudentDashboardController>();
  StudentDashboardController get instance => GetIt.instance<StudentDashboardController>();
}