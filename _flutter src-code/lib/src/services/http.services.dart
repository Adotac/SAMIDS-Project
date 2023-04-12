import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  static Future<http.Response> get(String url, {Map<String, String>? headers, Map<String, String>? query}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final response = await http.get(uri, headers: headers);
    return response;
  }

  static Future<http.Response> post(String url, {dynamic body, Map<String, String>? headers, Map<String, String>? query}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final response = await http.post(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return response;
  }

  static Future<http.Response> put(String url, {dynamic body, Map<String, String>? headers, Map<String, String>? query}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final response = await http.put(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return response;
  }

  static Future<http.Response> patch(String url, {dynamic body, Map<String, String>? headers, Map<String, String>? query}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final response = await http.patch(
      uri,
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );
    return response;
  }

  static Future<http.Response> delete(String url, {Map<String, String>? headers, Map<String, String>? query}) async {
    final uri = Uri.parse(url).replace(queryParameters: query);
    final response = await http.delete(
      uri,
      headers: headers,
    );
    return response;
  }
}