import 'package:samids_web_app/src/model/student_model.dart';

import 'faculty_model.dart';

class Subject {
  int subjectID;
  String subjectName;
  String subjectDescription;
  List<Student>? students;
  List<Faculty>? faculties;

  Subject({
    required this.subjectID,
    required this.subjectName,
    required this.subjectDescription,
    this.students,
    this.faculties,
  });

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectID: json['subjectID'],
      subjectName: json['subjectName'],
      subjectDescription: json['subjectDescription'],
      students: json['students'] != null
          ? List<Student>.from(
              json['students'].map((x) => Student.fromJson(x)),
            )
          : null,
      faculties: json['faculties'] != null
          ? List<Faculty>.from(
              json['faculties'].map((x) => Faculty.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subjectID'] = subjectID;
    data['subjectName'] = subjectName;
    data['subjectDescription'] = subjectDescription;
    if (students != null) {
      data['Students'] = students!.map((v) => v.toJson()).toList();
    }
    if (faculties != null) {
      data['Faculties'] = faculties!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}
