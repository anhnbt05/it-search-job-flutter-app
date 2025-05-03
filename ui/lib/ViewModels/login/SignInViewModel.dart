import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:ui/Views/admin/admin.dart';
import 'package:ui/Views/candidate/candidate.dart';
import 'package:ui/Views/recruiter/recruiter.dart';

import '../../Models/ResponseModel.dart';
import '../../Services/auth_refreshtoken_service.dart';
import '../../Services/auth_signin_service.dart';


class SignInViewModel extends ChangeNotifier {
  final AuthSignInService _authService = AuthSignInService();
  final AuthRefreshTokenService _refreshTokenService = AuthRefreshTokenService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool isLoading = false;
  String? errorMessage;

  Future<String?> signIn(BuildContext context, String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final ResponseModel result = await _authService.signIn(email, password);

      print('SignIn API Result: success=${result.success}, message=${result.message}, data=${result.data}');

      if (result.success == true && result.data != null) {
        final String? accessToken = result.data?['accessToken'];
        final String? refreshToken = result.data?['refreshToken'];

        if (accessToken == null || refreshToken == null) {
          errorMessage = "Không lấy được token, vui lòng thử lại.";
          return null;
        }

        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);

        final Map<String, dynamic> payload = Jwt.parseJwt(accessToken);
        print('Decoded JWT Payload: $payload');

        final String? role = payload['app_metadata']['role'];
        if (role == null) {
          errorMessage = "Không tìm thấy vai trò người dùng.";
          return null;
        }
        return role;
      } else {
        errorMessage = result.message ?? "Đăng nhập thất bại. Vui lòng kiểm tra tài khoản hoặc mật khẩu.";
        print('Error Message: $errorMessage');
      }
    } catch (e, stackTrace) {
      print('SignIn Error: $e');
      print('StackTrace: $stackTrace');
      errorMessage = "Có lỗi xảy ra, vui lòng thử lại sau.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAccessToken() async {
    try {
      final String? refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        errorMessage = "Không tìm thấy refreshToken.";
        notifyListeners();
        return;
      }

      final ResponseModel result = await _refreshTokenService.refreshAccessToken(refreshToken);

      print('Refresh Token Result: success=${result.success}, message=${result.message}, data=${result.data}');

      if (result.success && result.data != null) {
        final String? newAccessToken = result.data?['accessToken'];
        if (newAccessToken != null) {
          await _storage.write(key: 'accessToken', value: newAccessToken);
          print('🔑 New AccessToken Saved Successfully');
        } else {
          errorMessage = "Không lấy được accessToken mới.";
          notifyListeners();
        }
      } else {
        errorMessage = result.message ?? "Làm mới token thất bại.";
        notifyListeners();
      }
    } catch (e, stackTrace) {
      print('Refresh Token Exception: $e');
      print('StackTrace: $stackTrace');
      errorMessage = "Có lỗi khi làm mới token.";
      notifyListeners();
    }
  }

  Future<bool> isAccessTokenExpired() async {
    try {
      final String? accessToken = await _storage.read(key: 'accessToken');
      if (accessToken == null) {
        return true;
      }
      bool isExpired = Jwt.isExpired(accessToken);
      print('AccessToken expired: $isExpired');
      return isExpired;
    } catch (e) {
      print('Error checking token expiry: $e');
      return true;
    }
  }
}
//   void _navigateByRole(BuildContext context, String role) {
//     if (role == 'admin') {
//       // Mở AdminHomePage khi xong
//       // Navigator.of(context, rootNavigator: true).pushReplacement(
//       //   MaterialPageRoute(builder: (context) => AdminHomePage()),
//       // );
//     } else if (role == 'recruiter') {
//       Navigator.of(context, rootNavigator: true).pushReplacement(
//         MaterialPageRoute(builder: (context) => ManagementScreen()),
//       );
//     } else if (role == 'candidate') {
//       Navigator.of(context, rootNavigator: true).pushReplacement(
//         MaterialPageRoute(builder: (context) => HomeScreen()),
//       );
//     } else {
//       errorMessage = "Role không hợp lệ.";
//       notifyListeners();
//     }
//   }
// }
