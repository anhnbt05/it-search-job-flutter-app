import 'package:flutter/material.dart';
import '../../Models/ResponseModel.dart';
import '../../Services/auth_signup_service.dart';

class SignUpViewModel extends ChangeNotifier {
  final AuthSignUpService _service = AuthSignUpService();

  bool isLoading = false;
  bool isSuccess = false;
  String errorMessage = '';

  Future<ResponseModel> register(Map<String, dynamic> payload) async {
    isLoading = true;
    errorMessage = '';
    isSuccess = false;
    notifyListeners();

    final response = await _service.signUp(payload);

    isLoading = false;
    isSuccess = response.success;
    errorMessage = response.success ? '' : response.message;
    notifyListeners();

    return response;
  }
}
