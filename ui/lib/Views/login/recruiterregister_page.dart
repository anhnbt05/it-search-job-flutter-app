import 'package:flutter/material.dart';

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

  List<Map<String, dynamic>> companies = []; // [{id: , name: }]
  List<Map<String, dynamic>> locations = []; // [{id: , name: }]

  int? selectedCompanyId;
  int? selectedLocationId;

  bool showAddCompanyForm = false;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  void fetchCompanies() async {
    // Gọi API để lấy danh sách công ty
    // fake sample
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      companies = [
        {"id": 1, "name": "Công ty ABC"},
        {"id": 2, "name": "Công ty XYZ"},
      ];
    });
  }

  void fetchLocations(int companyId) async {
    // Gọi API lấy danh sách chi nhánh theo công ty
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      locations = [
        {"id": 10, "name": "Chi nhánh HN"},
        {"id": 11, "name": "Chi nhánh SG"},
      ];
    });
  }

  void addCompany() async {
    // Gửi API tạo công ty mới
    // sau khi tạo xong thì gán selectedCompanyId = newId và gọi lại fetchLocations
    final newCompanyId = 999; // giả định gọi API trả về
    setState(() {
      selectedCompanyId = newCompanyId;
      showAddCompanyForm = false;
    });
    fetchLocations(newCompanyId);
  }

  void createBranch() async {
    // Gọi API tạo chi nhánh → sau đó lấy lại danh sách chi nhánh
    final newLocationId = 555; // giả định
    setState(() {
      selectedLocationId = newLocationId;
    });
  }

  void registerRecruiter() {
    // Tổng hợp dữ liệu và gửi API
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
            ...companies.map((company) => CheckboxListTile(
              value: selectedCompanyId == company["id"],
              title: Text(company["name"]),
              onChanged: (_) {
                setState(() {
                  selectedCompanyId = company["id"];
                  fetchLocations(company["id"]);
                });
              },
            )),

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
                items: locations
                    .map((loc) => DropdownMenuItem<int>(
                  value: loc["id"],
                  child: Text(loc["name"]),
                ))
                    .toList(),
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
