import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Helpers/toastification.dart';
import '../../Models/ResponseModel.dart';
import '../../ViewModels/login/SignUpViewModel.dart';

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
        Navigator.pop(context);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(size.width * 0.08, size.height * 0.1, size.width * 0.08, 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Icon(Icons.person, size: 70, color: Colors.blueAccent)),
              SizedBox(height: 40),
              Text("Đăng ký ứng viên", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              SizedBox(height: 10),
              Text("Vui lòng điền thông tin bên dưới để tiếp tục", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
              SizedBox(height: 30),

              _buildDisplayText("Email", widget.email),
              _buildDisplayText("Họ và tên", widget.fullName),
              _buildDisplayText("Số điện thoại", widget.phone),
              SizedBox(height: 16),

              _buildMultilineField(_bioController, "Giới thiệu bản thân", Icons.info),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: InputDecoration(
                  labelText: "Cấp độ (Level)",
                  prefixIcon: Icon(Icons.star),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: [
                  DropdownMenuItem(value: "junior", child: Text("Junior")),
                  DropdownMenuItem(value: "mid", child: Text("Mid")),
                  DropdownMenuItem(value: "senior", child: Text("Senior")),
                ],
                onChanged: (value) => setState(() => selectedLevel = value),
                validator: (value) => value == null ? "Vui lòng chọn cấp độ" : null,
              ),
              SizedBox(height: 20),

              _buildTextField(
                _certificationsController,
                "Chứng chỉ (ngăn cách bởi dấu phẩy)",
                Icons.workspace_premium,
                "Ví dụ: AWS Certified Developer, Google Cloud Associate",
              ),
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitCandidate,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Đăng ký", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("← Quay lại", style: TextStyle(fontSize: 15, color: Colors.blue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, [String? hint]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? "Không được để trống" : null,
    );
  }

  Widget _buildMultilineField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? "Không được để trống" : null,
    );
  }

  Widget _buildDisplayText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
