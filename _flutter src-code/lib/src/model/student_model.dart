import 'package:samids_web_app/src/model/Subject_model.dart';
import 'package:samids_web_app/src/model/enum_values.dart';

class Student {
  int studentID;
  int studentNo;
  int rfid;
  String lastName;
  String firstName;
  String course;
  Year year;
  List<Subject>? subjects;

  Student({
    required this.studentID,
    required this.studentNo,
    required this.rfid,
    required this.lastName,
    required this.firstName,
    required this.course,
    required this.year,
    this.subjects,
  });

  static Student fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: json['studentid'],
      studentNo: json['studentno'],
      rfid: json['rfid'],
      lastName: json['lastname'],
      firstName: json['firstname'],
      course: json['course'],
      year: yearValues.map[json['year'].toLowerCase()]!,
      subjects: json['subjects'] != null
          ? List<Subject>.from(
              json['subjects'].map((x) => Subject.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentid'] = studentID;
    data['studentno'] = studentNo;
    data['rfid'] = rfid;
    data['lastname'] = lastName;
    data['firstname'] = firstName;
    data['course'] = course;
    data['year'] = yearValues.reverse[year]!.toString().toLowerCase();
    if (subjects != null) {
      data['subjects'] = subjects!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}

enum Year { first, second, third, fourth }

final yearValues = EnumValues({
  'first': Year.first,
  'second': Year.second,
  'third': Year.third,
  'fourth': Year.fourth
});
