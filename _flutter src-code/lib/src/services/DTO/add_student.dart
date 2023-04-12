import 'package:samids_web_app/src/model/subject_model.dart';

class AddStudentDto {
  final int studentNo;
  final String lastName;
  final String firstName;
  final String course;
  final String year;
  final List<Subject> subjects;

  AddStudentDto({
    required this.studentNo,
    required this.lastName,
    required this.firstName,
    required this.course,
    required this.year,
    required this.subjects,
  });

  factory AddStudentDto.fromJson(Map<String, dynamic> json) {
    final subjectsJson = json['subjects'] as List;
    final subjects = subjectsJson.map((subjectJson) {
      return Subject.fromJson(subjectJson as Map<String, dynamic>);
    }).toList();

    return AddStudentDto(
      studentNo: json['studentNo'] as int,
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
      course: json['course'] as String,
      year: json['year'] as String,
      subjects: subjects,
    );
  }

  Map<String, dynamic> toJson() => {
        'studentNo': studentNo,
        'lastName': lastName,
        'firstName': firstName,
        'course': course,
        'year': year,
        'subjects': subjects.map((subject) => subject.toJson()).toList(),
      };
}