import 'package:flutter/material.dart';
import '../../Models/ResponseModel.dart';
import '../../Services/auth_verifyresetpasswordotp_service.dart';

class VerifyResetPasswordOtpViewModel extends ChangeNotifier {
  final AuthVerifyResetPasswordOtpService _authService = AuthVerifyResetPasswordOtpService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<ResponseModel> verifyOtp(String email, String otp) async {
    setLoading(true);
    try {
      final response = await _authService.verifyResetPasswordOtp(email, otp);
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
