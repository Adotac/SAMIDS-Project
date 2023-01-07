import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:async';

import 'api_exceptions.dart';

class ApiController {
  final String _baseUrl = "https://localhost:7170/api/Student";

  Future<dynamic> get(String url) async {
    Response response;
    try {
      var dio = Dio();
      Response response = await dio.get(
        'https://localhost:7170/api/Student',
      );

      print(response.data);

      // print(_baseUrl + url);
      // print("as");
      // response = await dio.get();
      // print(response.data.toString());
      // print(response.data.toString());
      return response;
    } catch (e) {
      print(e);
    }
  }
}
