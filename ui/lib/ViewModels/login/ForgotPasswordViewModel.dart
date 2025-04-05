import 'package:flutter/material.dart';
import '../../Models/ResponseModel.dart';
import '../../Services/auth_forgetpassword_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> sendResetLink(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      ResponseModel response = await _authService.forgotPassword(email);

      if (response.success) {
      } else {
        _errorMessage = response.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
