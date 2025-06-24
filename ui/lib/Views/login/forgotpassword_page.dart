import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import '../../Helpers/toastification.dart';
import '../../ViewModels/login/ForgotPasswordViewModel.dart';
import '../../Constants/color_constants.dart'; // Thêm import này nếu có

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: screenHeight * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[


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

                    Text(
                      "Quên mật khẩu?",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: screenHeight * 0.035,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    Text(
                      "Nhập email đã đăng ký và chúng tôi sẽ gửi liên kết đặt lại mật khẩu cho bạn.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[700],
                        fontSize: screenHeight * 0.018,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    TextField(
                      controller: viewModel.emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: screenHeight * 0.02,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: "EMAIL",
                        labelStyle: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.grey.shade600,
                          fontSize: screenHeight * 0.016,
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
                          horizontal: 20,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.06),

                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.065,
                      child: ElevatedButton(
                        onPressed: () async {
                          final email = viewModel.emailController.text.trim();
                          if (email.isEmpty) {
                            showTopToastification(
                              content: "Vui lòng nhập email",
                              title: "Lỗi",
                              color: Colors.red,
                              icon: Icons.error_outline,
                            );
                            return;
                          }

                          await viewModel.sendResetLink(email);

                          if (viewModel.errorMessage != null) {
                            showTopToastification(
                              content: viewModel.errorMessage!,
                              title: "Thất bại",
                              color: Colors.red,
                              icon: Icons.error_outline,
                            );
                          } else {
                            showTopToastification(
                              content: "Đã gửi liên kết đặt lại mật khẩu đến email của bạn",
                              title: "Thành công",
                              color: Colors.green,
                              icon: Icons.check_circle_outline,
                            );
                            LoginNavigationViewModel().goToOtp(context, email);
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
                          "GỬI LIÊN KẾT ĐẶT LẠI",
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
                          "Quay lại đăng nhập",
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
          );
        },
      ),
    );
  }
}