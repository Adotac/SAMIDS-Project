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
      schedId: json['schedId'],
      subject:
          json['subject'] != null ? Subject.fromJson(json['subject']) : null,
      timeStart: DateTime.parse(json['timeStart']),
      timeEnd: DateTime.parse(json['timeEnd']),
      day: dayOfWeekValues.map[json['day']]!,
      room: json['room'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schedId'] = schedId;
    data['subject'] = subject?.toJson();
    data['timeStart'] = timeStart.toIso8601String();
    data['timeEnd'] = timeEnd.toIso8601String();
    data['day'] = dayOfWeekValues.reverse[day];
    data['room'] = room;
    return data;
  }
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

final dayOfWeekValues = EnumValues({
  0: DayOfWeek.monday,
  1: DayOfWeek.tuesday,
  2: DayOfWeek.wednesday,
  3: DayOfWeek.thursday,
  4: DayOfWeek.friday,
  5: DayOfWeek.saturday,
  6: DayOfWeek.sunday
});
