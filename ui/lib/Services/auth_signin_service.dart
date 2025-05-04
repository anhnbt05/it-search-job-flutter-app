import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ui/Helpers/helpers.dart';

import '../Models/ResponseModel.dart';

class AuthSignInService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<ResponseModel> signIn(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/sign-in');

    final deviceInfoDetails = await getDeviceInfo();

    final playerId = await getOneSignalPlayerId();

    if (playerId == null) {
      throw Exception("Missing player ID");
    }

    final payload = {
      'email': email,
      'password': password,
      'playerId': playerId,
      'deviceInfo': deviceInfoDetails['deviceInfo'],
      'platform': deviceInfoDetails['platform'],
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return ResponseModel(
          success: true,
          message: "Đăng nhập thành công.",
          messageList: ["Đăng nhập thành công."],
          data: responseData,
        );
      } else {
        return ResponseModel(
          success: false,
          message: responseData['message'] ?? "Đăng nhập thất bại.",
          messageList: [responseData['error'] ?? "Có lỗi xảy ra."],
          data: null,
        );
      }
    } catch (e) {
      print("Exception in signIn: $e");
      return ResponseModel(
        success: false,
        message: "Không thể kết nối đến máy chủ.",
        messageList: ["Không thể kết nối đến máy chủ."],
        data: null,
      );
    }
  }
}
