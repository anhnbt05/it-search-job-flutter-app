import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ Constants/api_constants.dart';
import '../Models/ResponseModel.dart';

class AuthVerifyResetPasswordOtpService {
  final String _baseUrl = APIConstants.baseUrl;

  Future<ResponseModel> verifyResetPasswordOtp(String email, String otp) async {
    print("Sending to: $_baseUrl/auth/verify-reset-password-otp");
    print("Email: $email");
    print("Body: ${json.encode({"email": email, "otp": otp})}");


    final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-reset-password-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            {"email": email,
            "otp": otp},
        ),
    );
    final responseData = json.decode(response.body);
    return ResponseModel.fromJson(responseData);
  }
}