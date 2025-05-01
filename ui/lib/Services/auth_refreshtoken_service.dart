import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Constants/api_constants.dart';
import '../Models/ResponseModel.dart';

class AuthRefreshTokenService {
  final String _baseUrl = APIConstants.baseUrl;

  Future<ResponseModel> refreshAccessToken(String refreshToken) async {
    final url = Uri.parse('$_baseUrl/auth/refresh-token');
    print("Refresh Token Request Body: ${json.encode({"refreshToken": refreshToken})}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "refreshToken": refreshToken,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return ResponseModel(
          success: true,
          messageList: ["Làm mới accessToken thành công."],
          message: "Làm mới accessToken thành công.",
          data: responseData,
        );
      } else {
        return ResponseModel(
          success: false,
          message: responseData['message'] ?? "Làm mới token thất bại.",
          messageList: [responseData['error'] ?? "Có lỗi xảy ra."],
          data: null,
        );
      }
    } catch (e) {
      print("Exception in refreshAccessToken: $e");
      return ResponseModel(
        success: false,
        message: "Không thể kết nối đến máy chủ.",
        messageList: ["Không thể kết nối đến máy chủ."],
        data: null,
      );
    }
  }
}
