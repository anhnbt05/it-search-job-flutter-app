import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ Constants/api_constants.dart';
import '../Models/ResponseModel.dart';

class AuthSignInService {
  final String _baseUrl = APIConstants.baseUrl;

  Future<ResponseModel> signIn(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/sign-in');
    print("Request Body: ${json.encode({"email": email, "password": password})}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": email,
          "password": password,
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return ResponseModel(
          success: true,
          message: "Đăng nhập thành công.",
          messageList: ["Đăng nhập thành công."] ,
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
