import 'package:samids_web_app/src/model/attendance_model.dart';

class AttendanceSearchParams {
  DateTime? date;
  String? room;
  int? studentNo;
  int? facultyNo;
  Remarks? remarks;
  int? subjectId;
  int? schedId;
  String? search;
  DateTime? fromDate;
  DateTime? toDate;
  int page;
  int pageSize;

  AttendanceSearchParams({
    this.date,
    this.room,
    this.studentNo,
    this.facultyNo,
    this.remarks,
    this.subjectId,
    this.schedId,
    this.search,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.pageSize = 10,
  });
}