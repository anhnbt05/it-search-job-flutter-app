import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Helpers/toastification.dart';
import '../../Models/Provinces.dart';
import '../../ViewModels/login/CompaniesViewModel.dart';
import '../../ViewModels/login/ProvincesViewModel.dart';

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
    Provider.of<ProvincesViewModel>(context, listen: false).fetchProvinces();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProvinceId == null) return;

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thêm công ty mới'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(size.width * 0.08, 24, size.width * 0.08, 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: Icon(Icons.apartment, size: 70, color: Colors.blueAccent)),
              SizedBox(height: 24),
              Text("Thông tin công ty", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),

              _buildTextField(_nameController, "Tên công ty", Icons.business),
              _buildTextField(_websiteController, "Website", Icons.language),
              _buildTextField(_descriptionController, "Mô tả", Icons.description, maxLines: 3),

              SizedBox(height: 24),
              Divider(),
              Text("Chi nhánh chính", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              SizedBox(height: 12),

              _buildTextField(_branchNameController, "Tên chi nhánh", Icons.location_on),
              _buildTextField(_addressController, "Địa chỉ", Icons.home),

              SizedBox(height: 16),
              provinceVM.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                value: _selectedProvinceId,
                decoration: InputDecoration(
                  labelText: 'Tỉnh/Thành phố',
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: provinceVM.provinces.map((cProvinces prov) {
                  return DropdownMenuItem<String>(
                    value: prov.id,
                    child: Text(prov.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedProvinceId = v),
                validator: (v) => v == null ? 'Vui lòng chọn' : null,
              ),

              SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: companyVM.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: companyVM.isLoading
                      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                      : Text("Lưu công ty", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Không được để trống' : null,
      ),
    );
  }
}
