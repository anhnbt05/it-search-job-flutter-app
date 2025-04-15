import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/LoginNavigationViewModel.dart';
import '../../Helpers/toastification.dart';
import '../../ViewModels/login/VerifyResetPasswordOtpViewModel.dart';

class OtpVerificationPage extends StatelessWidget {
  final String email;

  const OtpVerificationPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final otpController = TextEditingController();

    return Consumer<VerifyResetPasswordOtpViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.08,
              MediaQuery.of(context).size.height * 0.1,
              MediaQuery.of(context).size.width * 0.08,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.purple],
                      ),
                    ),
                    child: Icon(Icons.verified, size: 40, color: Colors.white),
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  "Xác minh OTP",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                ),
                SizedBox(height: 10),
                Text(
                  "Nhập mã OTP được gửi tới email: $email",
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "MÃ OTP",
                    labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final otp = otpController.text.trim();

                      if (otp.isEmpty) {
                        showTopToastification(
                          content: "Vui lòng nhập OTP",
                          title: "Thiếu thông tin",
                          color: Colors.orange,
                          icon: Icons.warning_amber_rounded,
                        );
                        return;
                      }

                      final response = await viewModel.verifyOtp(email, otp);

                      showTopToastification(
                        content: response.message,
                        title: response.success ? "Thành công" : "Lỗi",
                        color: response.success ? Colors.green : Colors.red,
                        icon: response.success ? Icons.check_circle_outline : Icons.error_outline,
                      );

                      if (response.success) {
                        LoginNavigationViewModel().goToResetPassword(context, email);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: viewModel.isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "XÁC MINH",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "← Quay lại",
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
