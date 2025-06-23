import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/ResetPasswordViewModel.dart';
import '../../Helpers/toastification.dart';
import '../../Constants/color_constants.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Consumer<ResetPasswordViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.08,
                vertical: screenHeight * 0.05,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Container(
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
                        child: Icon(Icons.lock_reset, size: 35, color: Colors.white),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Đặt lại mật khẩu",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: screenHeight * 0.035,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Nhập mật khẩu mới cho tài khoản:\n${widget.email}",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey[700],
                          fontSize: screenHeight * 0.018,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    TextFormField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenHeight * 0.02,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: "MẬT KHẨU MỚI",
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.016,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
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
                          horizontal: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập mật khẩu mới";
                        }
                        if (value.length < 6) {
                          return "Mật khẩu phải có ít nhất 6 ký tự";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenHeight * 0.02,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: "XÁC NHẬN MẬT KHẨU",
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.016,
                        ),
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
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
                          horizontal: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng xác nhận mật khẩu";
                        }
                        if (value != passwordController.text) {
                          return "Mật khẩu không khớp";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.06),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newPassword = passwordController.text.trim();
                            final response = await viewModel.verifyOtp(widget.email, newPassword);


                            if (response.success) {
                              Future.delayed(Duration(seconds: 2), () {
                                Navigator.popUntil(context, (route) => route.isFirst);
                              });
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: viewModel.isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          "XÁC NHẬN",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.white,
                            fontSize: screenHeight * 0.018,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Quay lại",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenHeight * 0.016,
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}