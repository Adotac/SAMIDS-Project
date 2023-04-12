import 'package:samids_web_app/src/model/subject_model.dart';

class Faculty {
  int facultyId;
  int facultyNo;
  String lastName;
  String firstName;
  List<Subject>? subjects;

  Faculty({
    required this.facultyId,
    required this.facultyNo,
    required this.lastName,
    required this.firstName,
    this.subjects,
  });

  static Faculty fromJson(Map<String, dynamic> json) {
    return Faculty(
      facultyId: json['FacultyId'],
      facultyNo: json['FacultyNo'],
      lastName: json['LastName'],
      firstName: json['FirstName'],
      subjects: json['Subjects'] != null
          ? List<Subject>.from(
              json['Subjects'].map((x) => Subject.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FacultyId'] = facultyId;
    data['FacultyNo'] = facultyNo;
    data['LastName'] = lastName;
    data['FirstName'] = firstName;
    if (subjects != null) {
      data['Subjects'] = subjects!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}