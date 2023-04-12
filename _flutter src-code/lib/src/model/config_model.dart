class Config {
  String currentTerm;
  String currentYear;
  int lateMinutes;
  int absentMinutes;

  Config({
    required this.currentTerm,
    required this.currentYear,
    required this.lateMinutes,
    required this.absentMinutes,
  });

  static Config fromJson(Map<String, dynamic> json) {
    return Config(
      currentTerm: json['CurrentTerm'],
      currentYear: json['CurrentYear'],
      lateMinutes: json['LateMinutes'],
      absentMinutes: json['AbsentMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CurrentTerm'] = currentTerm;
    data['CurrentYear'] = currentYear;
    data['LateMinutes'] = lateMinutes;
    data['AbsentMinutes'] = absentMinutes;
    return data;
  }
}