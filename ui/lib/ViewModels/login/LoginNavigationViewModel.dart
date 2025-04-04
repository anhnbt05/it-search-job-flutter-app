import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Views/login/forgotpassword_page.dart';

class LoginViewModel extends ChangeNotifier {
  void goToForgotPassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ForgotPasswordPage()),
    );
  }
}
