import 'package:samids_web_app/src/model/Subject_model.dart';
import 'package:samids_web_app/src/model/enum_values.dart';
import 'package:samids_web_app/src/model/faculty_model.dart';

// enum Weekday {
//   monday,
//   tuesday,
//   wednesday,
//   thursday,
//   friday,
//   saturday,
//   sunday,
// }

class SubjectSchedule {
  int schedId;
  Subject? subject;
  DateTime timeStart;
  DateTime timeEnd;
  String day;
  String room;
  Faculty? faculty;
  SubjectSchedule({
    required this.schedId,
    this.subject,
    required this.timeStart,
    required this.timeEnd,
    required this.day,
    required this.room,
    this.faculty,
  });

  static SubjectSchedule fromJson(Map<String, dynamic> json) {
    return SubjectSchedule(
      schedId: json['schedId'],
      subject:
          json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      timeStart: DateTime.parse(json['timeStart']),
      timeEnd: DateTime.parse(json['timeEnd']),
      day: displayDay(json['daysOfWeek'] ?? []),
      room: json['room'],
      faculty:
          json['faculty'] != null ? Faculty.fromJson(json['faculty']) : null,
    );
  }

  static String displayDay(List<dynamic> json) {
    List<DayOfWeek> days = json
        .map((e) => dayOfWeekValues.map[e['dayOfWeek']] ?? DayOfWeek.Mon)
        .toList();
    return days.map((day) => day.toString().split('.').last).join(', ');
  }
}

enum DayOfWeek { Mon, Tue, Wed, Thu, Fri, Sat, Sun }

final dayOfWeekValues = EnumValues({
  0: DayOfWeek.Sun,
  1: DayOfWeek.Mon,
  2: DayOfWeek.Tue,
  3: DayOfWeek.Wed,
  4: DayOfWeek.Thu,
  5: DayOfWeek.Fri,
  6: DayOfWeek.Sat,
});
