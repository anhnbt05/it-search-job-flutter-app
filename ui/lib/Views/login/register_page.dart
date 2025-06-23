import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Views/login/recruiterregister_page.dart';
import 'package:ui/Views/login/candidateregister_page.dart';
import 'package:ui/Constants/color_constants.dart';

import '../../ViewModels/login/CompaniesViewModel.dart';

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
  bool _obscurePassword = true;

  void _onNext() {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == 'recruiter') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider(
              create: (_) => CompaniesViewModel(),
              child: RecruiterRegisterPage(
                email: _emailController.text,
                password: _passwordController.text,
                fullName: _fullNameController.text,
                phone: _phoneController.text,
              ),
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                    child: Icon(Icons.person_add, size: 35, color: Colors.white),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tạo tài khoản",
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
                    "Vui lòng điền thông tin để đăng ký tài khoản",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[700],
                      fontSize: screenHeight * 0.018,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                _buildInputField(
                  controller: _emailController,
                  label: "EMAIL",
                  icon: Icons.email,
                  validator: _validateEmail,
                ),
                SizedBox(height: screenHeight * 0.025),

                _buildPasswordField(),
                SizedBox(height: screenHeight * 0.025),

                _buildInputField(
                  controller: _fullNameController,
                  label: "HỌ VÀ TÊN",
                  icon: Icons.person,
                ),
                SizedBox(height: screenHeight * 0.025),

                _buildInputField(
                  controller: _phoneController,
                  label: "SỐ ĐIỆN THOẠI",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: screenHeight * 0.025),

                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "VAI TRÒ",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.016,
                    ),
                    prefixIcon: Icon(Icons.work_outline, color: Colors.grey.shade600),
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
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: screenHeight * 0.02,
                    color: Colors.black87,
                  ),
                  hint: Text("Chọn vai trò", style: TextStyle(fontFamily: 'Poppins')),
                  items: [
                    DropdownMenuItem(
                      value: 'candidate',
                      child: Text("Ứng viên", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    DropdownMenuItem(
                      value: 'recruiter',
                      child: Text("Nhà tuyển dụng", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ],
                  validator: (value) => value == null ? "Vui lòng chọn vai trò" : null,
                  onChanged: (value) => setState(() => selectedRole = value),
                ),

                SizedBox(height: screenHeight * 0.06),

                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "TIẾP TỤC",
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
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: screenHeight * 0.02,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey.shade600,
          fontSize: screenHeight * 0.016,
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
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
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return "Không được để trống";
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    final screenHeight = MediaQuery.of(context).size.height;

    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: screenHeight * 0.02,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: "MẬT KHẨU",
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
        if (value == null || value.isEmpty) return "Không được để trống";
        if (value.length < 6) return "Mật khẩu phải dài ít nhất 6 ký tự";
        return null;
      },
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Không được để trống";
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value)) return "Email không hợp lệ";
    return null;
  }
}