import 'package:samids_web_app/src/services/http.services.dart';
import 'package:http/http.dart' as http;

class AttendanceService{
final HttpServices httpService;
final String _baseUrl = "https://localhost:7170/api";
  AttendanceService({required this.httpService});

  Future<http.Response> getRemarksCount() async {
    return await httpService.get('$_baseUrl/GetRemarksCount');
  }

  Future<http.Response> getRemarksCountByStudentNo(int studentNo) async {
    return await httpService.get('$_baseUrl/GetRemarksCount/$studentNo');
  }

  Future<http.Response> getRemarksCountByStudentNoAndDate(int studentNo, DateTime date) async {
    final formattedDate = date.toString().substring(0, 10); // format the date as YYYY-MM-DD
    return await httpService.get('$_baseUrl/GetRemarksCount/$studentNo&$formattedDate');
  }

  Future<http.Response> getAttendances() async {
    return await httpService.get('$_baseUrl/');
  }

  Future<http.Response> getAttendancesByDate(DateTime date) async {
    final formattedDate = date.toString().substring(0, 10); // format the date as YYYY-MM-DD
    return await httpService.get('$_baseUrl/$formattedDate');
  }

  Future<http.Response> getAttendancesByDateAndStudentNo(DateTime date, int studentNo) async {
    final formattedDate = date.toString().substring(0, 10); // format the date as YYYY-MM-DD
    return await httpService.get('$_baseUrl/$formattedDate&$studentNo');
  }

  Future<http.Response> getAttendancesByRoom(String room) async {
    return await httpService.get('$_baseUrl/$room');
  }

  Future<http.Response> getAttendancesByRoomAndRemarks(String room, String remarks) async {
    return await httpService.get('$_baseUrl/$room&$remarks');
  }

  Future<http.Response> getAttendancesByRoomAndStudentNo(String room, int studentNo) async {
    return await httpService.get('$_baseUrl/$room&$studentNo');
  }

  Future<http.Response> getAttendancesByStudentNo(int studentNo) async {
    return await httpService.get('$_baseUrl/$studentNo');
  }

  Future<http.Response> getAttendancesByStudentNoAndRemarks(int studentNo, String remarks) async {
    return await httpService.get('$_baseUrl/$studentNo&$remarks');
  }

  Future<http.Response> getAttendancesByRemarks(String remarks) async {
    return await httpService.get('$_baseUrl/$remarks');
  }

  Future<http.Response> getAttendancesByRoomAndStudentNoAndRemarks(String room, int studentNo, String remarks) async {
    return await httpService.get('$_baseUrl/$room&$studentNo&$remarks');
  }

  Future<http.Response> getStudentAttendance(int studentId) async {
    return await httpService.get('$_baseUrl/GetAllSA?studentId=$studentId');
  }

  Future<http.Response> getFacultyAttendance(int facultyId) async {
    return await httpService.get('$_baseUrl/GetAllFA?facultyId=$facultyId');
  }

  Future<http.Response> addAttendance(Map<String, dynamic> attendance) async {
    return await httpService.post('$_baseUrl/', body: attendance);
  }



}