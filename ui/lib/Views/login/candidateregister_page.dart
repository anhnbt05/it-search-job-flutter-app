import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ui/Views/login/verifyemail_page.dart';
import '../../Helpers/toastification.dart';
import '../../Models/ResponseModel.dart';
import '../../ViewModels/login/SignUpViewModel.dart';
import '../../Constants/color_constants.dart';
import '../../ViewModels/login/VerifyEmailViewModel.dart';

class CandidateRegisterPage extends StatefulWidget {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  const CandidateRegisterPage({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });

  @override
  State<CandidateRegisterPage> createState() => _CandidateRegisterPageState();
}

class _CandidateRegisterPageState extends State<CandidateRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _certificationsController = TextEditingController();
  String? selectedLevel;

  void _submitCandidate() async {
    if (_formKey.currentState!.validate()) {
      final bio = _bioController.text;
      final level = selectedLevel;
      final certifications = _certificationsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final payload = {
        "Email": widget.email,
        "Password": widget.password,
        "FullName": widget.fullName,
        "PhoneNumber": widget.phone,
        "Role": "candidate",
        "createCandidateDto": {
          "Bio": bio,
          "Level": level,
          "Certifications": certifications,
        },
      };

      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      final ResponseModel response = await viewModel.register(payload);

      if (response.success) {
        showTopToastification(
          title: 'Thành công',
          content: response.message,
          color: Colors.green,
          icon: Icons.check_circle,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => VerifyEmailViewModel(),
              child: VerifyemailPage(email: widget.email),
            ),
          ),
        );
      } else {
        showTopToastification(
          title: 'Lỗi',
          content: response.message,
          color: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<SignUpViewModel>(context).isLoading;
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
                    child: Icon(Icons.person, size: 35, color: Colors.white),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Đăng ký ứng viên",
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
                    "Vui lòng điền thông tin bên dưới để hoàn tất đăng ký",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[700],
                      fontSize: screenHeight * 0.018,
                      height: 1.5,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.05),

                _buildDisplayText("Email", widget.email),
                SizedBox(height: screenHeight * 0.02),
                _buildDisplayText("Họ và tên", widget.fullName),
                SizedBox(height: screenHeight * 0.02),
                _buildDisplayText("Số điện thoại", widget.phone),
                SizedBox(height: screenHeight * 0.04),

                _buildMultilineField(
                  controller: _bioController,
                  label: "GIỚI THIỆU BẢN THÂN (NẾU CÓ)",
                  icon: Icons.info,
                ),
                SizedBox(height: screenHeight * 0.025),

                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: "TRÌNH ĐỘ",
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.016,
                    ),
                    prefixIcon: Icon(Icons.star, color: Colors.grey.shade600),
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
                  hint: Text("Chọn trình độ", style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
                  items: [
                    DropdownMenuItem(
                      value: "intern",
                      child: Text("Intern", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    DropdownMenuItem(
                      value: "fresher",
                      child: Text("Fresher", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    DropdownMenuItem(
                      value: "mid",
                      child: Text("Mid", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    DropdownMenuItem(
                      value: "junior",
                      child: Text("Junior", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                    DropdownMenuItem(
                      value: "senior",
                      child: Text("Senior", style: TextStyle(fontFamily: 'Poppins')),
                    ),
                  ],
                  validator: (value) => value == null ? "Vui lòng chọn cấp độ" : null,
                  onChanged: (value) => setState(() => selectedLevel = value),
                ),
                SizedBox(height: screenHeight * 0.025),

                _buildTextField(
                  controller: _certificationsController,
                  label: "CHỨNG CHỈ NẾU CÓ (NGĂN CÁCH BỞI DẤU ,)",
                  icon: Icons.workspace_premium,
                  hint: "Ví dụ: AWS Certified Developer, Google Cloud Associate",
                ),
                SizedBox(height: screenHeight * 0.06),

                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitCandidate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "ĐĂNG KÝ",
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: screenHeight * 0.02,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey.shade600,
          fontSize: screenHeight * 0.012,
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
      validator: null,
    );
  }

  Widget _buildMultilineField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return TextFormField(
      controller: controller,
      maxLines: 4,
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
          fontSize: screenHeight * 0.014,
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
      validator: null,
    );
  }

  Widget _buildDisplayText(String title, String value) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: screenHeight * 0.018,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: "$title: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}