import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ Constants/api_constants.dart';
import '../Models/ResponseModel.dart';

class AuthSignUpService {
  final String _baseUrl = APIConstants.baseUrl;

  Future<ResponseModel> signUp(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/auth/sign-up');
    print("📤 Payload gửi lên:");
    print(json.encode(payload));

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print("📦 Status Code: ${response.statusCode}");
      print("📥 Response Body: ${response.body}");
      final responseData = json.decode(response.body);
      return ResponseModel.fromJson(responseData);
    } catch (e) {
      return ResponseModel(
        success: false,
        message: "Không thể kết nối đến máy chủ",
        messageList: ["Không thể kết nối đến máy chủ"],
        data: null,
      );
    }
  }
}
