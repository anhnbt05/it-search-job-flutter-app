import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
  final _descriptionsController = TextEditingController();

  File? _logoFile;
  String? _selectedJobType;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  Color _jobTypeBorderColor = Colors.grey.shade400;

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _logoFile = File(picked.path);
      });
    }
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
    bool isRequired = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              children: [
                if (isRequired) const TextSpan(
                  text: '*',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(
                    text: ':',
                    style: TextStyle(fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      selectedDate != null
                          ? DateFormat('dd/MM/yyyy').format(selectedDate)
                          : 'Chọn ngày',
                      style: TextStyle(
                        color: selectedDate != null ? Colors.black : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 20),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      locale: const Locale('vi', 'VN'),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              primary: Colors.blue,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                            datePickerTheme: DatePickerThemeData(
                                backgroundColor: Colors.white,
                                headerBackgroundColor: Colors.blue,
                                headerForegroundColor: Colors.white,
                                weekdayStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                                dayStyle: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                todayBackgroundColor: MaterialStateProperty.all(
                                  Colors.blue.withOpacity(0.1),
                                ),
                                todayForegroundColor: MaterialStateProperty.all(
                                  Colors.blue.shade600,
                                ),
                                dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.blue;
                                  }
                                  return null;
                                }),
                                dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return Colors.white;
                                  }
                                  return Colors.black87;
                                }),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                dayShape: MaterialStateProperty.all(
                                  CircleBorder(),
                                ),
                                cancelButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(
                                    Colors.grey,
                                  ),
                                )
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      onDateSelected(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobTypeDropdown() {
    final viewModel = Provider.of<WorkExperiencesViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Hình thức làm việc',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              children: const [
                TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                TextSpan(text: ':', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: const Text(
                'Chọn hình thức làm việc',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              value: _selectedJobType,
              items: viewModel.jobTypeOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedJobType = newValue;
                  _jobTypeBorderColor = Colors.grey.shade400;
                });
              },
              buttonStyleData: ButtonStyleData(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _jobTypeBorderColor),
                  color: Colors.white,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: MediaQuery.of(context).size.width - 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
              ),
              onMenuStateChange: (isOpen) {
                setState(() {
                  _jobTypeBorderColor = isOpen ? Colors.blue : Colors.grey.shade400;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Poppins',
              ),
              children: [
                if (isRequired)
                  const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                const TextSpan(text: ':', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            validator: isRequired
                ? (value) => (value == null || value.trim().isEmpty)
                ? 'Vui lòng nhập $label'
                : null
                : null,
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          automaticallyImplyLeading: false,
          backgroundColor: ColorConstants.appbarColor,
          centerTitle: true,
          title: const Text(
            "Thêm kinh nghiệm làm việc",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: _logoFile != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _logoFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(
                            Icons.business,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: IconButton(
                            onPressed: _pickLogo,
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
          
                  _buildTextField(
                    controller: _companyNameController,
                    label: 'Tên công ty',
                    hintText: 'Nhập tên công ty...',
                  ),
          
                  _buildTextField(
                    controller: _positionController,
                    label: 'Vị trí công việc',
                    hintText: 'Nhập vị trí công việc...',
                  ),
          
                  _buildDatePickerField(
                    label: 'Ngày bắt đầu',
                    selectedDate: _selectedStartDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedStartDate = date;
                        _startDateController.text =
                        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
                      });
                    },
                  ),
          
                  _buildDatePickerField(
                    label: 'Ngày kết thúc',
                    selectedDate: _selectedEndDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedEndDate = date;
                        _endDateController.text =
                        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
                      });
                    },
                    isRequired: false,
                  ),
          
                  _buildTextField(
                    controller: _locationController,
                    label: 'Địa điểm',
                    hintText: 'Nhập địa điểm...',
                  ),
          
                  _buildJobTypeDropdown(),
          
                  _buildTextField(
                    controller: _descriptionsController,
                    label: 'Mô tả công việc',
                    hintText: 'Nhập mô tả công việc...',
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                  ),
          
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Hủy button
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
          
                        // Xác nhận button
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final viewModel = Provider.of<WorkExperiencesViewModel>(
                                  context,
                                  listen: false);
                              final jobTypeApiValue =
                                  viewModel.jobTypeApiMapping[_selectedJobType] ?? '';
          
                              final success = await viewModel.addWorkExperience(
                                companyName: _companyNameController.text.trim(),
                                position: _positionController.text.trim(),
                                startDate: _startDateController.text.trim(),
                                endDate: _endDateController.text.trim().isEmpty
                                    ? null
                                    : _endDateController.text.trim(),
                                descriptions: _descriptionsController.text.trim(),
                                location: _locationController.text.trim(),
                                jobType: jobTypeApiValue,
                                logoFile: _logoFile,
                                context: context,
                              );
          
                              if (success && mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}