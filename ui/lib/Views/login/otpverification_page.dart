import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import '../../Helpers/toastification.dart';
import '../../ViewModels/login/VerifyResetPasswordOtpViewModel.dart';
import '../../Constants/color_constants.dart';

class OtpVerificationPage extends StatelessWidget {
  final String email;

  const OtpVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final otpController = TextEditingController();

    return Consumer<VerifyResetPasswordOtpViewModel>(
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
                      child: Icon(Icons.verified, size: 35, color: Colors.white),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Xác minh OTP",
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
                      "Nhập mã OTP 6 chữ số được gửi tới:\n$email",
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
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: screenHeight * 0.02,
                      color: Colors.black87,
                    ),
                    decoration: InputDecoration(
                      labelText: "MÃ OTP",
                      labelStyle: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey.shade600,
                        fontSize: screenHeight * 0.016,
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.grey.shade600),
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
                      counterText: "", // Ẩn counter
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.06),

                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.065,
                    child: ElevatedButton(
                      onPressed: () async {
                        final otp = otpController.text.trim();

                        if (otp.isEmpty) {
                          showTopToastification(
                            content: "Vui lòng nhập mã OTP",
                            title: "Thiếu thông tin",
                            color: Colors.orange,
                            icon: Icons.warning_amber_rounded,
                          );
                          return;
                        }

                        if (otp.length != 6) {
                          showTopToastification(
                            content: "Mã OTP phải có 6 chữ số",
                            title: "Lỗi",
                            color: Colors.red,
                            icon: Icons.error_outline,
                          );
                          return;
                        }

                        final response = await viewModel.verifyOtp(email, otp);


                        if (response.success) {
                          LoginNavigationViewModel().goToResetPassword(context, email);
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
                        "XÁC MINH",
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
        );
      },
    );
  }
}