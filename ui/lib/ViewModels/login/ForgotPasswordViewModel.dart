import 'package:flutter/material.dart';
import '../../Models/ResponseModel.dart';
import '../../Services/auth_forgetpassword_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final AuthForgetPasswordService _authService = AuthForgetPasswordService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _serverMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get serverMessage => _serverMessage;

  Future<void> sendResetLink(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _serverMessage = null;
    notifyListeners();

    try {
      ResponseModel response = await _authService.forgotPassword(email);
      _serverMessage = response.message;
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