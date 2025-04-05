import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/ResponseModel.dart';

class AuthService {
  final String _baseUrl = "https://aac0-14-169-56-27.ngrok-free.app";

  Future<ResponseModel> forgotPassword(String email) async {
    print("Sending to: $_baseUrl/auth/forget-password");
    print("Email: $email");
    print("Body: ${json.encode({"email": email})}");
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/forget-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"email": email}),
    );

    if (response.statusCode == 201) {
      return ResponseModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gửi liên kết đặt lại mật khẩu thất bại');
    }
  }
}
