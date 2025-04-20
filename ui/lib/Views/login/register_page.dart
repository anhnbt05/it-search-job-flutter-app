import 'package:flutter/material.dart';
import 'package:ui/Views/login/recruiterregister_page.dart';

import 'candidateregister_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedRole;

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == 'recruiter') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecruiterRegisterPage(
              email: _emailController.text,
              password: _passwordController.text,
              fullName: _fullNameController.text,
              phone: _phoneController.text,
            ),
          ),
        );
      } else if (selectedRole == 'candidate') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CandidateRegisterPage(
              email: _emailController.text,
              password: _passwordController.text,
              fullName: _fullNameController.text,
              phone: _phoneController.text,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Vui lòng chọn vai trò")),
        );
      }
    }
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
          20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.person_add, size: 70, color: Colors.blueAccent)),
              SizedBox(height: 40),
              Text("Tạo tài khoản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
              SizedBox(height: 10),
              Text("Vui lòng điền thông tin để đăng ký", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
              SizedBox(height: 30),

              _buildInputField(controller: _emailController, label: "Email", icon: Icons.email, validator: _validateEmail),
              SizedBox(height: 20),
              _buildInputField(controller: _passwordController, label: "Mật khẩu", icon: Icons.lock, obscure: true),
              SizedBox(height: 20),
              _buildInputField(controller: _fullNameController, label: "Họ và tên", icon: Icons.person),
              SizedBox(height: 20),
              _buildInputField(controller: _phoneController, label: "Số điện thoại", icon: Icons.phone, keyboardType: TextInputType.phone),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: "Vai trò",
                  prefixIcon: Icon(Icons.work_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                hint: Text("Chọn vai trò"),
                items: [
                  DropdownMenuItem(value: 'candidate', child: Text("Ứng viên")),
                  DropdownMenuItem(value: 'recruiter', child: Text("Nhà tuyển dụng")),
                ],
                validator: (value) => value == null ? "Vui lòng chọn vai trò" : null,
                onChanged: (value) => setState(() => selectedRole = value),
              ),
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("TIẾP TỤC", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("← Quay lại đăng nhập", style: TextStyle(fontSize: 15, color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: validator ?? (value) => (value == null || value.isEmpty) ? "Không được để trống" : null,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Không được để trống";
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value)) return "Email không hợp lệ";
    return null;
  }
}
