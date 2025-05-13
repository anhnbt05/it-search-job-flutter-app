import 'package:http/http.dart' as http;
import 'package:ui/Helpers/toastification.dart';
import 'dart:convert';

import '../Constants/api_constants.dart';
import '../Models/ResponseModel.dart';

class AuthResetpasswordService {
  final String _baseUrl = APIConstants.baseUrl;

  Future<ResponseModel> resetPassword(String email, String newPassword) async {
    print("Sending to: $_baseUrl/auth/reset-password");
    print("Email: $email");
    print("Body: ${json.encode({"email": email, "newPassword": newPassword})}");


    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(
        {"email": email,
          "newPassword": newPassword},
      ),
    );
    final responseData = json.decode(response.body);
    if (response.statusCode == 201) {
      showSuccessToastification(title: "Thành công", message: responseData["message"]);
    } else {
      print("Loi" + response.body);
    }
    return ResponseModel.fromJson(responseData);
  }
}