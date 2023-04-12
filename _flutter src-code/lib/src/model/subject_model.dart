import 'package:samids_web_app/src/model/faculty_model.dart';
import 'package:samids_web_app/src/model/student_model.dart';
import 'package:samids_web_app/src/model/subjectSchedule_model.dart';

class Subject {
  int subjectID;
  String subjectName;
  String subjectDescription;
  List<Student>? students;
  List<Faculty>? faculties;
  List<SubjectSchedule>? subjectSchedules;

  Subject({
    required this.subjectID,
    required this.subjectName,
    required this.subjectDescription,
    this.students,
    this.faculties,
    this.subjectSchedules,
  });

  static Subject fromJson(Map<String, dynamic> json) {
  return Subject(
    subjectID: json['SubjectID'],
    subjectName: json['SubjectName'],
    subjectDescription: json['SubjectDescription'],
    students: json['Students'] != null
        ? List<Student>.from(
            json['Students'].map((x) => Student.fromJson(x)),
          )
        : null,
    faculties: json['Faculties'] != null
        ? List<Faculty>.from(
            json['Faculties'].map((x) => Faculty.fromJson(x)),
          )
        : null,
    subjectSchedules: json['SubjectSchedules'] != null
        ? List<SubjectSchedule>.from(
            json['SubjectSchedules'].map((x) => SubjectSchedule.fromJson(x)),
          )
        : null,
  );
}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SubjectID'] = subjectID;
    data['SubjectName'] = subjectName;
    data['SubjectDescription'] = subjectDescription;
    if (students != null) {
      data['Students'] = students!.map((v) => v.toJson()).toList();
    }
    if (faculties != null) {
      data['Faculties'] = faculties!.map((v) => v.toJson()).toList();
    }
    if (subjectSchedules != null) {
      data['SubjectSchedules'] =
          subjectSchedules!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}