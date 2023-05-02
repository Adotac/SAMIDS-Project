import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:async';

import 'api_exceptions.dart';

class ApiController {
  final String _baseUrl = "https://localhost:7170/api/";
  final dio = Dio();
  
  Future<dynamic> get(String url) async {
    try {
      Response response = await dio.get(_baseUrl + url);

      print(response.data);
      return response;
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> post(String url, dynamic data) async {
    try {
      Response response = await dio.post(_baseUrl + url, data: data);

      print(response.data);
      return response;
    } catch (e) {
      print(e);
    }
  }
}
