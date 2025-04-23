import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Helpers/toastification.dart';
import '../../Models/CompanyLocations.dart';
import '../../Models/Companies.dart';
import '../../ViewModels/login/CompaniesViewModel.dart';
import '../../ViewModels/login/SignUpViewModel.dart';
import 'createbranch_page.dart';
import 'createcompany_page.dart';

class RecruiterRegisterPage extends StatefulWidget {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  const RecruiterRegisterPage({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    Key? key,
  }) : super(key: key);

  @override
  State<RecruiterRegisterPage> createState() => _RecruiterRegisterPageState();
}

class _RecruiterRegisterPageState extends State<RecruiterRegisterPage> {
  final TextEditingController _positionController = TextEditingController();
  List<cCompanyLocations> locations = [];
  String? selectedCompanyId;
  String? selectedLocationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CompaniesViewModel>(context, listen: false).fetchCompanies();
    });
  }

  void fetchLocations(String companyId) async {
    final vm = Provider.of<CompaniesViewModel>(context, listen: false);
    await vm.fetchBranches(companyId);
    setState(() {
      locations = vm.branches;
      selectedLocationId = null;
    });
  }

  void addCompany() async {
    final newCompany = await Navigator.push<cCompanies>(
      context,
      MaterialPageRoute(builder: (_) => CreateCompanyPage()),
    );

    if (newCompany != null && newCompany.ID != null) {
      final newCompanyId = newCompany.ID!;
      final newBranch = newCompany.CompanyLocations?.isNotEmpty == true
          ? newCompany.CompanyLocations!.first
          : null;

      setState(() {
        selectedCompanyId = newCompanyId;
        selectedLocationId = newBranch?.LocationID;
        locations = newBranch != null ? [newBranch] : [];
      });
    }
  }

  void createBranch() async {
    if (selectedCompanyId == null) return;

    final newBranch = await Navigator.push<cCompanyLocations>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateBranchPage(companyId: selectedCompanyId!),
      ),
    );

    if (newBranch != null) {
      setState(() {
        locations.add(newBranch);
        selectedLocationId = newBranch.LocationID;
      });
    }
  }

  Future<void> registerRecruiter() async {
    final signUpVM = Provider.of<SignUpViewModel>(context, listen: false);

    if (_positionController.text.isEmpty ||
        selectedCompanyId == null ||
        selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }

    final payload = {
      "Email": widget.email,
      "Password": widget.password,
      "FullName": widget.fullName,
      "PhoneNumber": widget.phone,
      "Role": "recruiter",
      "createRecruiterDto": {
        "Position": _positionController.text,
        "companyID": selectedCompanyId,
        "companyLocationID": selectedLocationId,
      }
    };

    final response = await signUpVM.register(payload);
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

  Widget buildCompaniesList() {
    final vm = Provider.of<CompaniesViewModel>(context);

    if (vm.isLoading) return Center(child: CircularProgressIndicator());
    if (vm.errorMessage != null) return Text("Lỗi: ${vm.errorMessage}");

    return Column(
      children: vm.companies.map((company) {
        final id = company.ID ?? "";
        return RadioListTile<String>(
          value: id,
          groupValue: selectedCompanyId,
          title: Text(company.Name ?? "Không tên"),
          onChanged: (value) {
            setState(() {
              selectedCompanyId = value;
            });
            if (value != null) fetchLocations(value);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpVM = Provider.of<SignUpViewModel>(context);
    final showBranchDropdown = selectedCompanyId != null && locations.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký nhà tuyển dụng")),
      body: signUpVM.isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _positionController,
              decoration: InputDecoration(labelText: 'Vị trí công việc'),
            ),
            SizedBox(height: 20),
            Text("Chọn công ty"),
            buildCompaniesList(),
            TextButton(
              onPressed: addCompany,
              child: Text("Thêm công ty mới"),
            ),
            SizedBox(height: 20),
            if (showBranchDropdown) ...[
              Text("Chọn chi nhánh"),
              DropdownButton<String>(
                value: selectedLocationId,
                hint: Text("Chọn chi nhánh"),
                isExpanded: true,
                items: locations.map((loc) {
                  final id = loc.LocationID ?? "";
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(loc.BranchName ?? "Không tên"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocationId = value;
                  });
                },
              ),
              TextButton(
                onPressed: createBranch,
                child: Text("Tạo chi nhánh mới"),
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: registerRecruiter,
              child: Text("Đăng ký"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
