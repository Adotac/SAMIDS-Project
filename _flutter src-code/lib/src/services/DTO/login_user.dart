class UserDto {
  String username;
  String password;

  UserDto({
    this.username = '',
    this.password = '',
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      username: json['Username'] ?? '',
      password: json['Password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['Username'] = this.username;
    data['Password'] = this.password;
    return data;
  }
}