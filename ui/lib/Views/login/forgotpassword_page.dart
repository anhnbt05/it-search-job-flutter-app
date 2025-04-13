import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ViewModels/login/ForgotPasswordViewModel.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Container(
              padding: EdgeInsets.fromLTRB(30, 80, 30, 0),
              constraints: BoxConstraints.expand(),
              color: Colors.white,
              child: SingleChildScrollView(
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
                            colors: [Colors.purple, Colors.blueAccent],
                          ),
                        ),
                        child: Icon(Icons.lock_reset, size: 40, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      "Quên mật khẩu?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Nhập email của bạn và chúng tôi sẽ gửi liên kết để đặt lại mật khẩu.",
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: viewModel.emailController,
                      style: TextStyle(fontSize: 18, color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "EMAIL",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
                        prefixIcon: Icon(Icons.email),
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
                          String email = viewModel.emailController.text.trim();
                          if (email.isNotEmpty) {
                            await viewModel.sendResetLink(email);
                            final message = viewModel.errorMessage ?? viewModel.serverMessage ?? "Đã gửi yêu cầu đặt lại mật khẩu.";
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)),
                               );
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: viewModel.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "GỬI LIÊN KẾT ĐẶT LẠI",
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
                          "← Quay lại đăng nhập",
                          style: TextStyle(fontSize: 15, color: Colors.blue),
                        ),
                      ),
                    )
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
