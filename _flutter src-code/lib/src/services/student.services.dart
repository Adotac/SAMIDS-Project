import 'dart:convert';

import 'package:samids_web_app/src/model/subject_model.dart';
import 'package:samids_web_app/src/services/DTO/add_student.dart';
import 'package:samids_web_app/src/services/DTO/add_studentsubject.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/update_student.dart';
import 'package:samids_web_app/src/services/helper.services.dart';
import 'package:samids_web_app/src/services/http.services.dart';

class StudentService {

  static const String _baseUrl = "https://localhost:7170/api";

  Future<CRUDReturn> getStudents() async {
    final response = await HttpService.get('$_baseUrl/students');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> getStudentById(int id) async {
    final response = await HttpService.get('$_baseUrl/students/byId/$id');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> getStudentByRfid(int rfid) async {
    final response = await HttpService.get('$_baseUrl/students/byRfid/$rfid');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> addStudent(AddStudentDto student) async {
    final response = await HttpService.post('$_baseUrl/students', body: student.toJson());
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> deleteStudent(int id) async {
    final response = await HttpService.delete('$_baseUrl/students?id=$id');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> updateStudent(StudentUpdateDto student) async {
    final response = await HttpService.patch('$_baseUrl/students', body: student.toJson());
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> addStudentSubject(AddStudentSubjectDto<int> request) async {
    final response = await HttpService.patch('$_baseUrl/students/addSubject', body: request.toJson());
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> addStudentSubjects(AddStudentSubjectDto<List<Subject>> request) async {
    final response = await HttpService.patch('$_baseUrl/students/addSubjects', body: request.toJson());
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> removeStudentSubject(AddStudentSubjectDto<int> request) async {
    final response = await HttpService.patch('$_baseUrl/students/removeSubject', body: request.toJson());
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> removeStudentSubjects(AddStudentSubjectDto<List<Subject>> request) async {
    final response = await HttpService.patch('$_baseUrl/students/removeSubjects', body: request.toJson());
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> getStudentClasses(DateTime date, int studentNo) async {
    final response = await HttpService.get('$_baseUrl/students/classesByDate?date=$date&studentNo=$studentNo');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> getStudentClassesByDay(DateTime  date, int studentNo) async {
    final response = await HttpService.get('$_baseUrl/students/classesByDay', query: {'date': '${toDateOnly(date)}', 'studentNo': '$studentNo'});
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }
}