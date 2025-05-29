import 'package:http/http.dart' as http;
import 'package:ui/Constants/api_constants.dart';
import 'dart:convert';

import '../Models/ResponseModel.dart';

class AuthForgetPasswordService {
  final String _baseUrl = APIConstants.baseUrl;

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
    print(responseData);
    return ResponseModel.fromJson(responseData);
  }
}
