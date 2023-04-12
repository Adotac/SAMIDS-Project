import 'package:samids_web_app/src/services/DTO/add_attendance.dart';
import 'package:samids_web_app/src/services/http.services.dart';
import 'package:http/http.dart' as http;

class AttendanceService {
  final String _baseUrl = "https://localhost:7170/api";

  Future<http.Response> getRemarksCount({int? studentNo, DateTime? date}) async {
    Map<String, String>? query;
    if (studentNo != null && date != null) {
      query = {'studentNo': studentNo.toString(), 'date': date.toIso8601String()};
    } else if (studentNo != null) {
      query = {'studentNo': studentNo.toString()};
    }
    return await HttpService.get("$_baseUrl/GetRemarksCount", query: query);
  }

  Future<http.Response> getAll({
    DateTime? date,
    String? room,
    int? studentNo,
    String? remarks,
  }) async {
    Map<String, String>? query = {};
    if (date != null) query['date'] = date.toIso8601String();
    if (room != null) query['room'] = room;
    if (studentNo != null) query['studentNo'] = studentNo.toString();
    if (remarks != null) query['remarks'] = remarks;

    return await HttpService.get(_baseUrl, query: query);
  }

  Future<http.Response> getAllSA({required int studentId}) async {
    return await HttpService.get("$_baseUrl/GetAllSA", query: {'studentId': studentId.toString()});
  }

  Future<http.Response> getAllFA({required int facultyId}) async {
    return await HttpService.get("$_baseUrl/GetAllFA", query: {'facultyId': facultyId.toString()});
  }

  Future<http.Response> addAttendance(AddAttendanceDto attendance) async {
    return await HttpService.post(_baseUrl, body: attendance);
  }
}
