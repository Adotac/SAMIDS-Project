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

  get subject => null;

  static Attendance fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendanceId'],
      student:
          json['student'] != null ? Student.fromJson(json['student']) : null,
      subjectSchedule: json['subjectSchedule'] != null
          ? SubjectSchedule.fromJson(json['subjectSchedule'])
          : null,
      device: json['device'] != null ? Device.fromJson(json['device']) : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      actualTimeIn: json['actualTimeIn'] != null
          ? DateTime.parse(json['actualTimeIn'])
          : null,
      actualTimeOut: json['actualTimeOut'] != null
          ? DateTime.parse(json['actualTimeOut'])
          : null,
      remarks: remarksValues.map[json['remarks']]!,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attendanceId'] = attendanceId;
    data['Student'] = student?.toJson();
    // data['SubjectSchedule'] = subjectSchedule?.toJson();
    data['Device'] = device?.toJson();
    data['Date'] = date?.toIso8601String();
    data['ActualTimeIn'] = actualTimeIn?.toIso8601String();
    data['ActualTimeOut'] = actualTimeOut?.toIso8601String();
    data['Remarks'] = remarksValues.reverse[remarks];
    return data;
  }
}

final remarksValues = EnumValues({
  0: Remarks.onTime,
  1: Remarks.late,
  2: Remarks.cutting,
  3: Remarks.absent
});
