import 'package:samids_web_app/src/model/device_model.dart';
import 'package:samids_web_app/src/model/enum_values.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';
enum Remarks { onTime, late, cutting, absent }

class Attendance {
  int attendanceId;
  Student? student;
  SubjectSchedule? subjectSchedule;
  Device? device;
  DateTime? date;
  DateTime? actualTimeIn;
  DateTime? actualTimeOut;
  Remarks remarks;

  Attendance({
    required this.attendanceId,
    this.student,
    this.subjectSchedule,
    this.device,
    this.date,
    this.actualTimeIn,
    this.actualTimeOut,
    required this.remarks,
  });

  static Attendance fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendanceId'],
      student:
          json['Student'] != null ? Student.fromJson(json['Student']) : null,
      subjectSchedule: json['SubjectSchedule'] != null
          ? SubjectSchedule.fromJson(json['SubjectSchedule'])
          : null,
      device:
          json['Device'] != null ? Device.fromJson(json['Device']) : null,
      date: json['Date'] != null ? DateTime.parse(json['Date']) : null,
      actualTimeIn: json['ActualTimeIn'] != null
          ? DateTime.parse(json['ActualTimeIn'])
          : null,
      actualTimeOut: json['ActualTimeOut'] != null
          ? DateTime.parse(json['ActualTimeOut'])
          : null,
      remarks: remarksValues.map[json['Remarks']]!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attendanceId'] = attendanceId;
    data['Student'] = student?.toJson();
    data['SubjectSchedule'] = subjectSchedule?.toJson();
    data['Device'] = device?.toJson();
    data['Date'] = date?.toIso8601String();
    data['ActualTimeIn'] = actualTimeIn?.toIso8601String();
    data['ActualTimeOut'] = actualTimeOut?.toIso8601String();
    data['Remarks'] = remarksValues.reverse[remarks];
    return data;
  }

}
final remarksValues = EnumValues({
  'OnTime': Remarks.onTime,
  'Late': Remarks.late,
  'Cutting': Remarks.cutting,
  'Absent': Remarks.absent
});