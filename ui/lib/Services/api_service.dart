import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://it-searcj-job-app-be.onrender.com';

  Future<http.Response> postWithToken({
    required String endpoint,
    required Map<String, dynamic> body,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getWithToken({
    required String endpoint,
    required String accessToken,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    return await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );
  }
}
