import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:ui/Helpers/helpers.dart';

import '../Models/ResponseModel.dart';

class AuthSignUpService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<ResponseModel> signUp(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/auth/sign-up');

    final deviceInfoDetails = await getDeviceInfo();

    final playerId = await getOneSignalPlayerId();

    final data = {
      ...payload,
      'playerId': playerId,
      'deviceInfo': deviceInfoDetails['deviceInfo'],
      'platform': deviceInfoDetails['platform'],
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

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
