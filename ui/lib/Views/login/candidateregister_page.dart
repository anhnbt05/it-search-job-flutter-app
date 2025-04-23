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

    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký ứng viên")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text("Thông tin cá nhân", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(height: 12),

              Text("Email: ${widget.email}"),
              Text("Họ và tên: ${widget.fullName}"),
              Text("Số điện thoại: ${widget.phone}"),
              SizedBox(height: 20),

              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Giới thiệu bản thân (Bio)",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Vui lòng nhập giới thiệu bản thân" : null,
              ),
              SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedLevel,
                decoration: InputDecoration(
                  labelText: "Cấp độ (Level)",
                  border: OutlineInputBorder(),
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

              TextFormField(
                controller: _certificationsController,
                decoration: InputDecoration(
                  labelText: "Chứng chỉ (ngăn cách bởi dấu phẩy)",
                  hintText: "Ví dụ: AWS Certified Developer, Google Cloud Associate",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? "Vui lòng nhập ít nhất 1 chứng chỉ" : null,
              ),
              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitCandidate,
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Đăng ký", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
