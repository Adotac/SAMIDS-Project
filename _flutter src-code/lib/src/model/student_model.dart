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
      studentID: json['StudentID'],
      studentNo: json['StudentNo'],
      rfid: json['Rfid'],
      lastName: json['LastName'],
      firstName: json['FirstName'],
      course: json['Course'],
      year: yearValues.map[json['Year']]!,
      subjects: json['Subjects'] != null
          ? List<Subject>.from(
              json['Subjects'].map((x) => Subject.fromJson(x)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StudentID'] = studentID;
    data['StudentNo'] = studentNo;
    data['Rfid'] = rfid;
    data['LastName'] = lastName;
    data['FirstName'] = firstName;
    data['Course'] = course;
    data['Year'] = yearValues.reverse[year];
    if (subjects != null) {
      data['Subjects'] = subjects!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}

enum Year { first, second, third, fourth }

final yearValues = EnumValues({
  'First': Year.first,
  'Second': Year.second,
  'Third': Year.third,
  'Fourth': Year.fourth
});

