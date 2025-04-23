import 'package:flutter/material.dart';
import 'package:ui/Services/auth_verifyemail_service.dart';
import '../../Models/ResponseModel.dart';
import '../../Services/auth_verifyresetpasswordotp_service.dart';

class VerifyEmailViewModel extends ChangeNotifier {
  final AuthVerifyemailService _authService = AuthVerifyemailService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<ResponseModel> verifyemail(String email, String otp) async {
    setLoading(true);
    try {
      final response = await _authService.verifyemail(email, otp);
      return response;
    } catch (e) {
      return ResponseModel(
        success: false,
        message: "Lỗi không xác định: $e",
        messageList: ["Lỗi không xác định: $e"],
      );
    } finally {
      setLoading(false);
    }
  }
}
