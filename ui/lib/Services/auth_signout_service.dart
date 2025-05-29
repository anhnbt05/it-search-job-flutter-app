import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:ui/Helpers/toastification.dart';

import '../Helpers/helpers.dart';
import '../Models/ResponseModel.dart';

class AuthSignOutService {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<ResponseModel> signOut(BuildContext context) async {
    final url = Uri.parse('$_baseUrl/auth/sign-out');
    final validToken = await getValidAccessToken(context);
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $validToken',
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body);
      print(response.statusCode);
      print(responseData);
      if (response.statusCode == 201) {
        return ResponseModel(
          success: true,
          message: "Đăng xuất thành công.",
          messageList: ["Đăng xuất thành công."],
          data: responseData,
        );
      } else {
        return ResponseModel(
          success: false,
          message: responseData['message'] ?? "Đăng xuất thất bại.",
          messageList: [responseData['error'] ?? "Có lỗi xảy ra."],
          data: null,
        );
      }
    } catch (e) {
      print("Exception in signOut: $e");
      return ResponseModel(
        success: false,
        message: "Không thể kết nối đến máy chủ.",
        messageList: ["Không thể kết nối đến máy chủ."],
        data: null,
      );
    }
  }
}