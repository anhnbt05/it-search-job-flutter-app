import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:ui/Views/admin/admin.dart';
import 'package:ui/Views/candidate/candidate.dart';
import 'package:ui/Views/recruiter/recruiter.dart';

import '../../Models/ResponseModel.dart';
import '../../Services/auth_signin_service.dart';

class SignInViewModel extends ChangeNotifier {
  final AuthSignInService _authService = AuthSignInService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isLoading = false;
  String? errorMessage;

  Future<void> signIn(BuildContext context, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ResponseModel result = await _authService.signIn(email, password);
      String accessToken = result.data['accessToken'];
      Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
      print('Payload: $payload');

      if (result.success) {
        String accessToken = result.data['accessToken'];
        String refreshToken = result.data['refreshToken'];

        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
        print('Payload: $payload');

        String role = payload['role'];

        // Navigation theo role
        if (role == 'admin') {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => AdminHomePage()),
          // );
        } else if (role == 'recruiter') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManagementScreen()),
          );
        } else if (role == 'candidate') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          errorMessage = "Role không hợp lệ";
        }
      } else {
        errorMessage = result.message;
      }
    } catch (e) {
      errorMessage = "Có lỗi xảy ra, vui lòng thử lại.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
