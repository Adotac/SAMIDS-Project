import 'dart:convert';
import 'package:samids_web_app/src/services/DTO/add_faculty.dart';
import 'package:samids_web_app/src/services/DTO/add_facultySubject.dart';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/update_faculty.dart';
import 'package:samids_web_app/src/services/http.services.dart';

class FacultyService {
  static const String _baseUrl = "https://localhost:7170/api";
  
  static Future<CRUDReturn> getFaculties() async {
    final response = await HttpService.get('$_baseUrl/Faculty');
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> getFacultyById(int id) async {
    final response = await HttpService.get('$_baseUrl/Faculty/$id');
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> addFaculty(AddFacultyDto faculty) async {
    final body = json.encode(faculty.toJson());
    final response = await HttpService.post('$_baseUrl/Faculty', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> deleteFaculty(int id) async {
    final response = await HttpService.delete('$_baseUrl/Faculty?id=$id');
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> updateFaculty(FacultyUpdateDto request) async {
    final body = json.encode(request.toJson());
    final response = await HttpService.patch('$_baseUrl/Faculty', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> removeFacultySubjects(
      FacultySubjectDto<dynamic> request) async {
    final body = json.encode(request.toJson());
    final response =
        await HttpService.patch('$_baseUrl/Faculty/RemoveSubjects', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }

  static Future<CRUDReturn> addFacultySubjects(
      FacultySubjectDto<dynamic> request) async {
    final body = json.encode(request.toJson());
    final response =
        await HttpService.patch('$_baseUrl/Faculty/AddSubjects', body: body);
    final jsonResponse = json.decode(response.body);
    return CRUDReturn.fromJson(jsonResponse);
  }
}