import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModels/login/CompaniesViewModel.dart';
import '../../Models/Companies.dart';

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

  List<Map<String, dynamic>> locations = [];
  int? selectedCompanyId;
  int? selectedLocationId;

  bool showAddCompanyForm = false;

  @override
  void initState() {
    super.initState();
    Provider.of<CompaniesViewModel>(context, listen: false).fetchCompanies();
  }

  void fetchLocations(int companyId) async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      locations = [
        {"id": 10, "name": "Chi nhánh HN"},
        {"id": 11, "name": "Chi nhánh SG"},
      ];
    });
  }

  void addCompany() async {
    final newCompanyId = 999;
    setState(() {
      selectedCompanyId = newCompanyId;
      showAddCompanyForm = false;
    });
    fetchLocations(newCompanyId);
  }

  void createBranch() async {
    final newLocationId = 555;
    setState(() {
      selectedLocationId = newLocationId;
    });
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
      "companyLocationId": selectedLocationId
    };

    print("Gửi đăng ký: $payload");
    // Gọi API ở đây
  }

  Widget buildCompaniesList() {
    final companiesVM = Provider.of<CompaniesViewModel>(context);

    if (companiesVM.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (companiesVM.errorMessage != null) {
      return Text("Lỗi: ${companiesVM.errorMessage}");
    }

    return Column(
      children: companiesVM.companies.map((cCompanies company) {
        return CheckboxListTile(
          value: selectedCompanyId == int.tryParse(company.ID ?? ''),
          title: Text(company.Name ?? "Không tên"),
          onChanged: (_) {
            setState(() {
              selectedCompanyId = int.tryParse(company.ID ?? '');
              if (selectedCompanyId != null) {
                fetchLocations(selectedCompanyId!);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Đăng ký nhà tuyển dụng")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _positionController, decoration: InputDecoration(labelText: 'Vị trí công việc')),
            const SizedBox(height: 20),
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
                  ElevatedButton(onPressed: addCompany, child: Text("Tạo công ty"))
                ],
              ),
            const SizedBox(height: 20),
            if (selectedCompanyId != null) ...[
              Text("Chọn chi nhánh"),
              DropdownButton<int>(
                value: selectedLocationId,
                hint: Text("Chọn chi nhánh"),
                items: locations.map((loc) {
                  return DropdownMenuItem<int>(
                    value: loc["id"],
                    child: Text(loc["name"]),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedLocationId = value),
              ),
              TextButton(onPressed: createBranch, child: Text("Tạo chi nhánh mới"))
            ],
            const SizedBox(height: 30),
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
