import 'package:samids_web_app/src/services/helper.services.dart';

class UserRegisterDto {
  int studentNo;
  String firstName;
  String lastName;
  String email;
  String password;
  Types type;
  String schoolYear;

  UserRegisterDto({
    required this.studentNo,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    required this.password,
    required this.type,
    this.schoolYear = '',
  });

  factory UserRegisterDto.fromJson(Map<String, dynamic> json) {
    return UserRegisterDto(
      studentNo: json['StudentNo'],
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      email: json['Email'] ?? '',
      password: json['Password'],
      type: typeFromJson(json['Type']),
      schoolYear: json['SchoolYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['StudentNo'] = this.studentNo;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Email'] = this.email;
    data['Password'] = this.password;
    data['Type'] = typeToJson(this.type);
    data['SchoolYear'] = this.schoolYear;
    return data;
  }
}
