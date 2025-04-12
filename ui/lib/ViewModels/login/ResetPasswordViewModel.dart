import 'package:flutter/material.dart';
import 'package:ui/Services/auth_resetpassword_service.dart';
import '../../Models/ResponseModel.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthResetpasswordService _authService = AuthResetpasswordService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<ResponseModel> verifyOtp(String email, String newPassword) async {
    setLoading(true);
    try {
      final response = await _authService.resetPassword(email, newPassword);
      return response;
    } catch (e) {
      return ResponseModel(success: false, message: "Lỗi không xác định: $e");
    } finally {
      setLoading(false);
    }
  }
}
