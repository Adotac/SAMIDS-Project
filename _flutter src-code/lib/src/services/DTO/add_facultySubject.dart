class FacultySubjectDto<T> {
  int facultyNo;
  T subject;

  FacultySubjectDto({
    required this.facultyNo,
    required this.subject,
  });

  factory FacultySubjectDto.fromJson(Map<String, dynamic> json) {
    return FacultySubjectDto(
      facultyNo: json['FacultyNo'],
      subject: json['Subject'] as T,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FacultyNo'] = this.facultyNo;
    data['Subject'] = this.subject;
    return data;
  }
}