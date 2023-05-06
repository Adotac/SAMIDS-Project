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
      studentID: json['studentID'] ?? 0,
      studentNo: json['studentNo'] ?? 0,
      rfid: json['rfid'] ?? 0,
      lastName: json['lastName'] ?? '',
      firstName: json['firstName'] ?? '',
      course: json['course'] ?? '',
      year: yearValues.map[json['year']] ?? Year.First,
      subjects: json['subjects'] != null
          ? List<Subject>.from(
              json['subjects'].map((x) => Subject.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentID'] = studentID;
    data['studentNo'] = studentNo;
    data['rfid'] = rfid;
    data['lastName'] = lastName;
    data['firstName'] = firstName;
    data['course'] = course;
    data['year'] = yearValues.reverse[year];
    if (subjects != null) {
      data['subjects'] = subjects!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}

enum Year { First, Second, Third, Fourth, Fifth }

final yearValues = EnumValues({
  0: Year.First,
  1: Year.Second,
  2: Year.Third,
  3: Year.Fourth,
  4: Year.Fifth
});
