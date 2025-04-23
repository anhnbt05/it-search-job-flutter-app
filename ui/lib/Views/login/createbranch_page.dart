import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helpers/toastification.dart';
import '../../Models/Provinces.dart';
import '../../ViewModels/login/CompaniesViewModel.dart';
import '../../ViewModels/login/ProvincesViewModel.dart';

class CreateBranchPage extends StatefulWidget {
  final String companyId;

  const CreateBranchPage({required this.companyId});

  @override
  State<CreateBranchPage> createState() => _CreateBranchPageState();
}

class _CreateBranchPageState extends State<CreateBranchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedProvinceId;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Provider.of<ProvincesViewModel>(context, listen: false).fetchProvinces();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedProvinceId == null) return;

    setState(() => isSubmitting = true);

    final vm = Provider.of<CompaniesViewModel>(context, listen: false);
    final response = await vm.addBranch(
      companyId: widget.companyId,
      branchName: _branchNameController.text,
      address: _addressController.text,
      locationId: _selectedProvinceId!,
    );

    setState(() => isSubmitting = false);

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

  @override
  Widget build(BuildContext context) {
    final provinceVM = Provider.of<ProvincesViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text("Tạo chi nhánh mới")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _branchNameController,
                decoration: InputDecoration(labelText: "Tên chi nhánh"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Địa chỉ"),
                validator: (value) => value!.isEmpty ? "Không được để trống" : null,
              ),
              SizedBox(height: 16),
              provinceVM.isLoading
                  ? CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                value: _selectedProvinceId,
                decoration: InputDecoration(labelText: "Chọn Tỉnh/Thành"),
                items: provinceVM.provinces
                    .map((cProvinces provinces) => DropdownMenuItem<String>(
                  value: provinces.id,
                  child: Text(provinces.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProvinceId = value;
                  });
                },
                validator: (value) =>
                value == null ? "Vui lòng chọn tỉnh/thành" : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: isSubmitting ? null : _submit,
                child: isSubmitting
                    ? CircularProgressIndicator()
                    : Text("Tạo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
