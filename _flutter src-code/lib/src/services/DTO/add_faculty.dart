import 'package:samids_web_app/src/model/subject_model.dart';

class AddFacultyDto {
  int facultyNo;
  String lastName;
  String firstName;
  List<Subject>? subjects;

  AddFacultyDto({
    required this.facultyNo,
    this.lastName = '',
    this.firstName = '',
    this.subjects,
  });

  factory AddFacultyDto.fromJson(Map<String, dynamic> json) {
    return AddFacultyDto(
      facultyNo: json['FacultyNo'],
      lastName: json['LastName'] ?? '',
      firstName: json['FirstName'] ?? '',
      subjects: (json['Subjects'] as List<dynamic>?)
          ?.map((subject) => Subject.fromJson(subject))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FacultyNo'] = facultyNo;
    data['LastName'] = lastName;
    data['FirstName'] = firstName;
    data['Subjects'] = subjects?.map((subject) => subject.toJson()).toList();
    return data;
  }
}