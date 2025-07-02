import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import 'package:ui/ViewModels/login/SignInViewModel.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Constants/color_constants.dart';

class LoginPage extends StatefulWidget {
  final void Function(String, String) onLoginSuccess;
  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    bool isValidEmail(String email) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegex.hasMatch(email);
    }
    return ChangeNotifierProvider(
      create: (context) => SignInViewModel(),
      child: Scaffold(
        body: Consumer<SignInViewModel>(
          builder: (context, signInViewModel, child) {
            return SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.25,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://qwilddaqnrznqbhuskzx.supabase.co/storage/v1/object/public/files//job-background.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.2),
                              BlendMode.darken,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    ColorConstants.primaryColor,
                                    ColorConstants.primaryColor.withOpacity(0.8)
                                  ],
                                ),
                              ),
                              child: Icon(Icons.key, size: 45, color: Colors.white),
                            ),

                            SizedBox(height: screenHeight * 0.03),
                            Text(
                              "Xin chào\nChào mừng bạn trở lại",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: screenHeight * 0.035,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),

                            TextField(
                              controller: _usernameController,
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenHeight * 0.02,
                                  color: Colors.black87
                              ),
                              decoration: InputDecoration(
                                labelText: "EMAIL",
                                labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade600,
                                  fontSize: screenHeight * 0.018,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(Icons.email, color: Colors.grey.shade600),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02,
                                    horizontal: 20
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.025),

                            TextField(
                              controller: _passwordController,
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: screenHeight * 0.02,
                                  color: Colors.black87
                              ),
                              obscureText: _obscureText,
                              decoration: InputDecoration(
                                labelText: "MẬT KHẨU",
                                labelStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey.shade600,
                                  fontSize: screenHeight * 0.018,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureText ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey.shade600,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02,
                                    horizontal: 20
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.04),

                            SizedBox(
                              width: double.infinity,
                              height: screenHeight * 0.065,
                              child: ElevatedButton(
                                onPressed: signInViewModel.isLoading
                                    ? null
                                    : () async {
                                  final email = _usernameController.text.trim();
                                  final password = _passwordController.text.trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    showTopToastification(
                                      title: "Lỗi",
                                      content: "Vui lòng nhập đầy đủ email và mật khẩu",
                                      color: Colors.red,
                                      icon: Icons.warning_amber_rounded,
                                    );
                                    return;
                                  }
                                  if (!isValidEmail(email)) {
                                    showTopToastification(
                                      title: "Lỗi",
                                      content: "Định dạng email không hợp lệ",
                                      color: Colors.red,
                                      icon: Icons.warning_amber_rounded,
                                    );
                                    return;
                                  }

                                  final Map<String, dynamic>? payload =
                                  await signInViewModel.signIn(
                                    context,
                                    _usernameController.text,
                                    _passwordController.text,
                                  );
                                  if (signInViewModel.errorMessage != null) {
                                    showTopToastification(
                                      content: signInViewModel.errorMessage!,
                                      title: "Thất bại",
                                      color: Colors.red,
                                      icon: Icons.error_outline,
                                    );
                                  } else if (payload != null) {
                                    final String role =
                                    payload['app_metadata']['role'];
                                    final String userId = payload['sub'];
                                    widget.onLoginSuccess(role, userId);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorConstants.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: signInViewModel.isLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  "ĐĂNG NHẬP",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => LoginNavigationViewModel().goToRegister(context),
                                  child: Text(
                                    "ĐĂNG KÝ TÀI KHOẢN",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: screenHeight * 0.015,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => LoginNavigationViewModel().goToForgotPassword(context),
                                  child: Text(
                                    "QUÊN MẬT KHẨU",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: screenHeight * 0.015,
                                      color: ColorConstants.primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}