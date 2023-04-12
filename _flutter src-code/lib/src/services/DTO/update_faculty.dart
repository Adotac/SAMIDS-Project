class FacultyUpdateDto {
  int facultyNo;
  String firstName;
  String lastName;

  FacultyUpdateDto({
    required this.facultyNo,
    this.firstName = '',
    this.lastName = '',
  });

  factory FacultyUpdateDto.fromJson(Map<String, dynamic> json) {
    return FacultyUpdateDto(
      facultyNo: json['FacultyNo'],
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['FacultyNo'] = facultyNo;
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    return data;
  }
}