import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/CompanyLocations.dart';
import '../../Models/Companies.dart';
import '../../ViewModels/login/CompaniesViewModel.dart';
import 'createbranch_page.dart';

class RecruiterRegisterPage extends StatefulWidget {
  final String email;
  final String password;
  final String fullName;
  final String phone;

  RecruiterRegisterPage({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
  });

  @override
  State<RecruiterRegisterPage> createState() => _RecruiterRegisterPageState();
}

class _RecruiterRegisterPageState extends State<RecruiterRegisterPage> {
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _companyWebsiteController = TextEditingController();

  List<cCompanyLocations> locations = [];
  String? selectedCompanyId;
  String? selectedLocationId;
  bool showAddCompanyForm = false;

  @override
  void initState() {
    super.initState();
    Provider.of<CompaniesViewModel>(context, listen: false).fetchCompanies();
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
    final newCompanyId = "999"; // Dummy ID
    setState(() {
      selectedCompanyId = newCompanyId;
      showAddCompanyForm = false;
      locations = [];
      selectedLocationId = null;
    });
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

  void registerRecruiter() {
    final payload = {
      "email": widget.email,
      "password": widget.password,
      "fullName": widget.fullName,
      "phone": widget.phone,
      "role": "recruiter",
      "position": _positionController.text,
      "companyId": selectedCompanyId,
      "companyLocationId": selectedLocationId,
    };
    print("Gửi đăng ký: $payload");
  }

  Widget buildCompaniesList() {
    final vm = Provider.of<CompaniesViewModel>(context);

    if (vm.isLoading) return CircularProgressIndicator();
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
    final showBranchDropdown = selectedCompanyId != null && locations.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký nhà tuyển dụng")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _positionController, decoration: InputDecoration(labelText: 'Vị trí công việc')),
            SizedBox(height: 20),
            Text("Chọn công ty"),
            buildCompaniesList(),
            TextButton(
              onPressed: () {
                setState(() {
                  showAddCompanyForm = !showAddCompanyForm;
                });
              },
              child: Text(showAddCompanyForm ? "Ẩn form thêm công ty" : "Thêm công ty mới"),
            ),
            if (showAddCompanyForm)
              Column(
                children: [
                  TextField(controller: _companyNameController, decoration: InputDecoration(labelText: "Tên công ty")),
                  TextField(controller: _companyWebsiteController, decoration: InputDecoration(labelText: "Website")),
                  ElevatedButton(onPressed: addCompany, child: Text("Tạo công ty")),
                ],
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
              TextButton(onPressed: createBranch, child: Text("Tạo chi nhánh mới")),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: registerRecruiter,
              child: Text("Đăng ký"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
