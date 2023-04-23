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
      currentTerm: json['currentTerm'],
      currentYear: json['currentYear'],
      lateMinutes: json['lateMinutes'],
      absentMinutes: json['absentMinutes'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentTerm'] = currentTerm;
    data['currentYear'] = currentYear;
    data['lateMinutes'] = lateMinutes;
    data['absentMinutes'] = absentMinutes;
    return data;
  }
}
