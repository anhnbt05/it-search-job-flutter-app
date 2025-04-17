import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/ResetPasswordViewModel.dart';
import 'package:ui/Views/login/resetpassword_page.dart';

import '../../Views/login/forgotpassword_page.dart';
import '../../Views/login/otpverification_page.dart';
import 'VerifyResetPasswordOtpViewModel.dart';

class LoginNavigationViewModel extends ChangeNotifier {
  void goToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
    );
  }

  void goToOtp(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChangeNotifierProvider(
              create: (_) => VerifyResetPasswordOtpViewModel(),
              child: OtpVerificationPage(email: email),
            ),
      ),
    );
  }
  void goToResetPassword(BuildContext context, String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChangeNotifierProvider(
              create: (_) => ResetPasswordViewModel(),
              child: ResetPasswordPage(email: email),
            ),
      ),
    );
  }
}