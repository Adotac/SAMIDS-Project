import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:samids_web_app/src/model/enum_values.dart';
import 'package:samids_web_app/src/model/student_model.dart';

class User {
  int userId;
  Student? student;
  String firstName;
  String lastName;
  String email;
  Uint8List passwordHash;
  Uint8List passwordSalt;
  Types type;
  String schoolYear;
  bool deleted;

  User({
    required this.userId,
    this.student,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.type,
    required this.schoolYear,
    required this.deleted,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      student:
          json['student'] != null ? Student.fromJson(json['student']) : null,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      passwordHash: base64.decode(json['passwordHash']),
      passwordSalt: base64.decode(json['passwordSalt']),
      type: typesValues.map[json['type']]!,
      schoolYear: json['schoolYear'],
      deleted: json['deleted'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['UserId'] = userId;
    data['Student'] = student?.toJson();
    data['FirstName'] = firstName;
    data['LastName'] = lastName;
    data['Email'] = email;
    data['PasswordHash'] = base64.encode(passwordHash);
    data['PasswordSalt'] = base64.encode(passwordSalt);
    data['Type'] = typesValues.reverse[type];
    data['SchoolYear'] = schoolYear;
    data['Deleted'] = deleted;
    return data;
  }

  get studentNo => student!.studentNo;
}



enum Types { student, faculty }

final typesValues = EnumValues({0: Types.student, 1: Types.faculty});