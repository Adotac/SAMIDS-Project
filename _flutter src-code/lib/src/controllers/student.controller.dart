import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';


class StudentController extends ChangeNotifier {
  static StudentController get instance => GetIt.instance<StudentController>();

  static void initialize() =>
      GetIt.instance.registerSingleton<StudentController>(StudentController());

  final List<Student> _students = [];
  List<Student> get students => _students;

  void addStudent(Student student) {
    _students.add(student);
    notifyListeners();
  }

  void removeStudent(Student student) {
    _students.remove(student);
    notifyListeners();
  }

  void updateStudent(Student oldStudent, Student newStudent) {
    final index = _students.indexOf(oldStudent);
    _students[index] = newStudent;
    notifyListeners();
  }
}
