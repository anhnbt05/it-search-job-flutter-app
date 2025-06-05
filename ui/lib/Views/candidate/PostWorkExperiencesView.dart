import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Constants/color_constants.dart';
import '../../ViewModels/candidate/WorkExperiencesViewModel.dart';

class PostWorkExperiencesView extends StatefulWidget {
  const PostWorkExperiencesView({Key? key}) : super(key: key);

  @override
  State<PostWorkExperiencesView> createState() => _PostWorkExperiencesViewState();
}

class _PostWorkExperiencesViewState extends State<PostWorkExperiencesView> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _locationController = TextEditingController();
  final _jobTypeController = TextEditingController();
  final _descriptionsController = TextEditingController();

  File? _logoFile;

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }

  Widget customTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text, // đã có rồi
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: requiredField
                ? (value) =>
            (value == null || value.trim().isEmpty) ? 'Vui lòng nhập $label' : null
                : null,
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _companyNameController.dispose();
    _positionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _locationController.dispose();
    _jobTypeController.dispose();
    _descriptionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Theme(
        data: ThemeData(fontFamily: "Poppins"),
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 45,
            automaticallyImplyLeading: false,
            backgroundColor: ColorConstants.appbarColor,
            centerTitle: true,
            title: Center(
              child: Text(
                "Thêm kinh nghiệm làm việc",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _logoFile != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _logoFile!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                      : Center(
                                    child: Text(
                                      'Chưa chọn logo',
                                      style: TextStyle(color: Colors.grey.shade700),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: IconButton(
                                    onPressed: _pickLogo,
                                    icon: const Icon(Icons.upload_file, color: Colors.blue),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          customTextField(label: 'Tên công ty', controller: _companyNameController),
                          customTextField(label: 'Vị trí công việc', controller: _positionController),
                          customTextField(
                            label: 'Ngày bắt đầu (YYYY-MM-DD)',
                            controller: _startDateController,
                            keyboardType: TextInputType.datetime,
                          ),
                          customTextField(
                            label: 'Ngày kết thúc (YYYY-MM-DD)',
                            controller: _endDateController,
                            keyboardType: TextInputType.datetime,
                            requiredField: false,
                          ),
                          customTextField(label: 'Địa điểm', controller: _locationController),
                          customTextField(label: 'Hình thức làm việc (full-time, part-time,...)', controller: _jobTypeController),
                          customTextField(
                            label: 'Mô tả công việc (nhập tự do)',
                            controller: _descriptionsController,
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            requiredField: false,
                          ),

                          const SizedBox(height: 30),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Nút Huỷ
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Quay lại
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade400,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  ),
                                  child: const Text(
                                    'Huỷ',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                                  ),
                                ),

                                // Nút Xác nhận
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final rawDescriptions = _descriptionsController.text.trim();
                                      final descriptionsList = rawDescriptions
                                          .split('\n')
                                          .map((e) => e.trim())
                                          .where((e) => e.isNotEmpty)
                                          .toList()
                                          .cast<String>();
                                      final workExperienceDto = {
                                        "CompanyName": _companyNameController.text.trim(),
                                        "Position": _positionController.text.trim(),
                                        "StartDate": _startDateController.text.trim(),
                                        "EndDate": _endDateController.text.trim(),
                                        "Location": _locationController.text.trim(),
                                        "JobType": _jobTypeController.text.trim(),
                                        "Descriptions": descriptionsList,
                                      };

                                      final success = await Provider.of<WorkExperiencesViewModel>(context, listen: false)
                                          .addWorkExperience(workExperienceDto: workExperienceDto, context: context);

                                      if (success) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.1),
                                  ),
                                  child: const Text(
                                    'Xác nhận',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
