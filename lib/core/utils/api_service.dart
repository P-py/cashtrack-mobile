import 'dart:convert';
import 'package:cashtrack/features/auth/data/auth_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final AuthService auth;

  ApiService({required this.baseUrl, required this.auth});

  Map<String, String> _defaultHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (auth.token != null) {
      headers['Authorization'] = 'Bearer ${auth.token}';
    }
    return headers;
  }

  Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: _defaultHeaders());
  }

  Future<http.Response> post(String path, Map body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: _defaultHeaders(), body: jsonEncode(body));
  }

  Future<http.Response> put(String path, Map body) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.put(uri, headers: _defaultHeaders(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: _defaultHeaders());
  }
}
