import 'package:samids_web_app/src/model/Subject_model.dart';
import 'package:samids_web_app/src/model/enum_values.dart';

class SubjectSchedule {
  int schedId;
  Subject? subject;
  DateTime timeStart;
  DateTime timeEnd;
  DayOfWeek day;
  String room;

  SubjectSchedule({
    required this.schedId,
    this.subject,
    required this.timeStart,
    required this.timeEnd,
    required this.day,
    required this.room,
  });

  static SubjectSchedule fromJson(Map<String, dynamic> json) {
    return SubjectSchedule(
      schedId: json['SchedId'],
      subject: json['Subject'] != null
          ? Subject.fromJson(json['Subject'])
          : null,
      timeStart: DateTime.parse(json['TimeStart']),
      timeEnd: DateTime.parse(json['TimeEnd']),
      day: dayOfWeekValues.map[json['Day']]!,
      room: json['Room'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SchedId'] = schedId;
    data['Subject'] = subject?.toJson();
    data['TimeStart'] = timeStart.toIso8601String();
    data['TimeEnd'] = timeEnd.toIso8601String();
    data['Day'] = dayOfWeekValues.reverse[day];
    data['Room'] = room;
    return data;
  }
}

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

final dayOfWeekValues = EnumValues({
  0: DayOfWeek.monday,
  1: DayOfWeek.tuesday,
  2: DayOfWeek.wednesday,
  3: DayOfWeek.thursday,
  4: DayOfWeek.friday,
  5: DayOfWeek.saturday,
  6: DayOfWeek.sunday
});