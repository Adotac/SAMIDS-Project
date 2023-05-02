class UserUpdateDto {
  String userId;
  String firstName;
  String lastName;
  String email;

  UserUpdateDto({
    required this.userId,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
  });

  factory UserUpdateDto.fromJson(Map<String, dynamic> json) {
    return UserUpdateDto(
      userId: json['UserId'] ?? '',
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      email: json['Email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['UserId'] = this.userId;
    data['FirstName'] = this.firstName;
    data['LastName'] = this.lastName;
    data['Email'] = this.email;
    return data;
  }
}