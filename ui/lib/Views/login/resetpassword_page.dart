import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void resetPassword() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width * 0.08,
          MediaQuery.of(context).size.height * 0.1,
          MediaQuery.of(context).size.width * 0.08,
          0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(Icons.lock_reset, size: 70, color: Colors.blueAccent),
              ),
              SizedBox(height: 40),
              Text(
                "Đặt lại mật khẩu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              SizedBox(height: 10),
              Text(
                "Vui lòng nhập mật khẩu mới cho tài khoản ${widget.email}",
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
              SizedBox(height: 30),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mật khẩu mới",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Mật khẩu phải có ít nhất 6 ký tự";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Xác nhận mật khẩu",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value != passwordController.text) {
                    return "Mật khẩu không khớp";
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : resetPassword,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("← Quay lại", style: TextStyle(fontSize: 15, color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
