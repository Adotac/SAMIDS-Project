// import 'package:samids_web_app/src/services/helper.services.dart';

// class UserRegisterDto {
//   int idNo;
//   String email;
//   String password;
//   Types type;
//   String schoolYear;

//   UserRegisterDto({
//     required this.idNo,
//     this.firstName = '',
//     this.lastName = '',
//     this.email = '',
//     required this.password,
//     required this.type,
//     this.schoolYear = '',
//     required int idNo,
//   });

//   factory UserRegisterDto.fromJson(Map<String, dynamic> json) {
//     return UserRegisterDto(
//       idNo: json['idNo'],
//       firstName: json['FirstName'] ?? '',
//       lastName: json['LastName'] ?? '',
//       email: json['Email'] ?? '',
//       password: json['Password'],
//       type: typeFromJson(json['Type']),
//       schoolYear: json['SchoolYear'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = Map<String, dynamic>();
//     data['StudentNo'] = this.idNo;
//     data['FirstName'] = this.firstName;
//     data['LastName'] = this.lastName;
//     data['Email'] = this.email;
//     data['Password'] = this.password;
//     data['Type'] = typeToJson(this.type);
//     data['SchoolYear'] = this.schoolYear;
//     return data;
//   }
// }
