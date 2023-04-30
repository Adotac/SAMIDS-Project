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
    try {
      return Faculty(
        facultyId: json['facultyId'],
        facultyNo: json['facultyNo'],
        lastName: json['lastName'],
        firstName: json['firstName'],
        subjects: json['subjects'] != null
            ? List<Subject>.from(
                json['subjects']
                    .map((x) => x != null &&
                            x['faculties'] != null &&
                            x['faculties'].first != null
                        ? Subject.fromJson(x)
                        : null)
                    .where((x) => x != null),
              )
            : null,
      );
    } catch (e, stacktrace) {
      print('fromJson $e $stacktrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['facultyId'] = facultyId;
    data['facultyNo'] = facultyNo;
    data['lastName'] = lastName;
    data['firstName'] = firstName;
    if (subjects != null) {
      data['subjects'] = subjects!.map((x) => x.toJson()).toList();
    }
    return data;
  }
}
