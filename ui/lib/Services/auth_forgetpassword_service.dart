import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/ResponseModel.dart';

class AuthForgetPasswordService {
  final String _baseUrl = "https://it-searcj-job-app-be.onrender.com";

  Future<ResponseModel> forgotPassword(String email) async {
    // print("Sending to: $_baseUrl/auth/forget-password");
    // print("Email: $email");
    // print("Body: ${json.encode({"email": email})}");
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/forget-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email}),
    );
    final responseData = json.decode(response.body);
    return ResponseModel.fromJson(responseData);
  }
}
