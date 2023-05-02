import 'dart:convert';
import 'package:samids_web_app/src/services/DTO/crud_return.dart';
import 'package:samids_web_app/src/services/DTO/update_user.dart';
import 'package:samids_web_app/src/services/http.services.dart';

class UserService {
  static const String _baseUrl = "https://localhost:7170/api/users";

  Future<CRUDReturn> getUsers() async {
    final response = await HttpService.get(_baseUrl);
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> getById(int id) async {
    final response = await HttpService.get('$_baseUrl/$id');
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }

  Future<CRUDReturn> updateUser(UserUpdateDto user) async {
    final body = json.encode(user.toJson());
    final response = await HttpService.patch(_baseUrl, body: body);
    return CRUDReturn.fromJson(jsonDecode(response.body));
  }
}
