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

    return Scaffold(
      appBar: AppBar(title: Text('Thêm công ty mới')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên công ty'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _websiteController,
                decoration: InputDecoration(labelText: 'Website'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              Divider(),
              Text('Thông tin chi nhánh chính', style: TextStyle(fontWeight: FontWeight.bold)),
              TextFormField(
                controller: _branchNameController,
                decoration: InputDecoration(labelText: 'Tên chi nhánh'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Địa chỉ'),
                validator: (v) => v!.isEmpty ? 'Không được để trống' : null,
              ),
              SizedBox(height: 16),
              provinceVM.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                value: _selectedProvinceId,
                decoration: InputDecoration(labelText: 'Chọn Tỉnh/Thành'),
                items: provinceVM.provinces
                    .map((cProvinces prov) => DropdownMenuItem<String>(
                  value: prov.id,
                  child: Text(prov.name),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedProvinceId = v),
                validator: (v) => v == null ? 'Vui lòng chọn' : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: companyVM.isLoading ? null : _submit,
                  child: companyVM.isLoading
                      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                      : Text('Lưu công ty'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}