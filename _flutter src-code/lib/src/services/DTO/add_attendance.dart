class AddAttendanceDto {
  int studentNo;
  String room;
  DateTime date;
  DateTime actualTimeIn;
  DateTime actualTimeout;

  AddAttendanceDto({
    required this.studentNo,
    this.room = '',
    required this.date,
    required this.actualTimeIn,
    required this.actualTimeout,
  });

  factory AddAttendanceDto.fromJson(Map<String, dynamic> json) {
    return AddAttendanceDto(
      studentNo: json['studentNo'],
      room: json['room'] ?? '',
      date: DateTime.parse(json['date']),
      actualTimeIn: DateTime.parse(json['actualTimeIn']),
      actualTimeout: DateTime.parse(json['actualTimeout']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['studentNo'] = this.studentNo;
    data['room'] = this.room;
    data['date'] = this.date.toIso8601String();
    data['actualTimeIn'] = this.actualTimeIn.toIso8601String();
    data['actualTimeout'] = this.actualTimeout.toIso8601String();
    return data;
  }
}