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
      await vm.fetchBranches(widget.companyId);
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Tạo chi nhánh mới"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(size.width * 0.08, 24, size.width * 0.08, 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(child: Icon(Icons.location_city, size: 70, color: Colors.blueAccent)),
              SizedBox(height: 24),
              Text("Thông tin chi nhánh", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),

              _buildTextField(_branchNameController, "Tên chi nhánh", Icons.business),
              _buildTextField(_addressController, "Địa chỉ", Icons.location_on),

              SizedBox(height: 16),
              provinceVM.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                value: _selectedProvinceId,
                decoration: InputDecoration(
                  labelText: "Tỉnh/Thành phố",
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: provinceVM.provinces.map((cProvinces provinces) {
                  return DropdownMenuItem<String>(
                    value: provinces.id,
                    child: Text(provinces.name),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedProvinceId = value),
                validator: (value) =>
                value == null ? "Vui lòng chọn tỉnh/thành" : null,
              ),

              SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isSubmitting
                      ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                      : Text("Tạo", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? "Không được để trống" : null,
      ),
    );
  }
}
