class AddStudentSubjectDto<T> {
  int studentNo;
  T? subject;

  AddStudentSubjectDto({
    required this.studentNo,
    this.subject,
  });

  factory AddStudentSubjectDto.fromJson(Map<String, dynamic> json) {
    return AddStudentSubjectDto(
      studentNo: json['StudentNo'],
      subject: json['Subject'] as T?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['StudentNo'] = this.studentNo;
    data['Subject'] = this.subject;
    return data;
  }
}