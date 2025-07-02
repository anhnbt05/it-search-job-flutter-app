import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helpers/toastification.dart';
import '../../Models/Provinces.dart';
import '../../ViewModels/login/CompaniesViewModel.dart';
import '../../ViewModels/login/ProvincesViewModel.dart';
import '../../Constants/color_constants.dart';

class CreateCompanyPage extends StatefulWidget {
  @override
  State<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedProvinceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ProvincesViewModel>(context, listen: false).fetchProvinces();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProvinceId == null) {
      showTopToastification(
        title: "Thiếu thông tin",
        content: "Vui lòng điền đầy đủ thông tin",
        color: Colors.orange,
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    final vm = Provider.of<CompaniesViewModel>(context, listen: false);
    final response = await vm.addCompany(
      name: _nameController.text,
      websiteUrl: _websiteController.text,
      description: _descriptionController.text,
      branchName: _branchNameController.text,
      address: _addressController.text,
      locationId: _selectedProvinceId!,
    );

    if (response.success) {
      await vm.fetchCompanies();
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

  @override
  Widget build(BuildContext context) {
    final provinceVM = Provider.of<ProvincesViewModel>(context);
    final companyVM = Provider.of<CompaniesViewModel>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Thêm công ty mới',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: ColorConstants.appbarColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.03,
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
                    child: Icon(Icons.apartment, size: 35, color: Colors.white),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Thông tin công ty",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.028,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.025),

                _buildTextField(
                  controller: _nameController,
                  label: "TÊN CÔNG TY",
                  icon: Icons.business,
                ),
                SizedBox(height: screenHeight * 0.025),

                _buildTextField(
                  controller: _websiteController,
                  label: "WEBSITE",
                  icon: Icons.language,
                ),
                SizedBox(height: screenHeight * 0.025),

                _buildMultilineField(
                  controller: _descriptionController,
                  label: "MÔ TẢ",
                  icon: Icons.description,
                ),

                SizedBox(height: screenHeight * 0.04),
                Divider(color: Colors.grey.shade300),
                SizedBox(height: screenHeight * 0.04),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Chi nhánh chính",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight * 0.028,
                      color: Colors.black87,
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.025),

                _buildTextField(
                  controller: _branchNameController,
                  label: "TÊN CHI NHÁNH",
                  icon: Icons.location_on,
                ),
                SizedBox(height: screenHeight * 0.025),

                _buildTextField(
                  controller: _addressController,
                  label: "ĐỊA CHỈ",
                  icon: Icons.home,
                ),
                SizedBox(height: screenHeight * 0.025),

                provinceVM.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                  value: _selectedProvinceId,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    labelText: 'TỈNH/THÀNH PHỐ',
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey.shade600,
                      fontSize: screenHeight * 0.016,
                    ),
                    prefixIcon: Icon(Icons.map, color: Colors.grey.shade600),
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
                  items: provinceVM.provinces.map((cProvinces prov) {
                    return DropdownMenuItem<String>(
                      value: prov.id,
                      child: Text(
                        prov.name,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 17),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedProvinceId = v),
                  validator: (v) => v == null ? 'Vui lòng chọn tỉnh/thành phố' : null,
                ),

                SizedBox(height: screenHeight * 0.06),

                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.065,
                  child: ElevatedButton(
                    onPressed: companyVM.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: companyVM.isLoading
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      "LƯU CÔNG TY",
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
      validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
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
      maxLines: 3,
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
      validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
    );
  }
}