import 'package:samids_web_app/src/services/helper.services.dart';

class StudentUpdateDto {
  int studentNo;
  String lastName;
  String firstName;
  String course;
  Year year;

  StudentUpdateDto({
    required this.studentNo,
    this.lastName = '',
    this.firstName = '',
    this.course = '',
    required this.year,
  });

  factory StudentUpdateDto.fromJson(Map<String, dynamic> json) {
    return StudentUpdateDto(
      studentNo: json['StudentNo'],
      lastName: json['LastName'] ?? '',
      firstName: json['FirstName'] ?? '',
      course: json['Course'] ?? '',
      year: yearFromJson(json['Year']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['StudentNo'] = studentNo;
    data['LastName'] = lastName;
    data['FirstName'] = firstName;
    data['Course'] = course;
    data['Year'] = yearToJson(year);
    return data;
  }
}