import 'package:samids_web_app/src/model/Subject_model.dart';
import 'package:samids_web_app/src/model/enum_values.dart';

enum Weekday {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

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
      day: dayOfWeekValues.map[json['daysOfWeek']] ?? DayOfWeek.M,
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

enum DayOfWeek { M, T, W, TH, F, S, SU }

final dayOfWeekValues = EnumValues({
  0: DayOfWeek.M,
  1: DayOfWeek.T,
  2: DayOfWeek.W,
  3: DayOfWeek.TH,
  4: DayOfWeek.F,
  5: DayOfWeek.S,
  6: DayOfWeek.SU
});
