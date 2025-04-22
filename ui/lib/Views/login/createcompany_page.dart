import 'package:flutter/material.dart';
import '../../Models/CompanyLocations.dart';
import '../../Models/Companies.dart';

class CreateCompanyPage extends StatefulWidget {
  @override
  State<CreateCompanyPage> createState() => _CreateCompanyPageState();
}

class _CreateCompanyPageState extends State<CreateCompanyPage> {
  final _nameController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _addressController = TextEditingController();

  void submit() {
    final newCompany = cCompanies(
      ID: "new-id", // giả lập ID hoặc để backend trả về
      Name: _nameController.text,
      WebsiteUrl: _websiteController.text,
      Description: _descriptionController.text,
      CompanyLocations: [
        cCompanyLocations(
          LocationID: "new-location-id", // giả lập ID hoặc để backend trả về
          BranchName: _branchNameController.text,
          Address: _addressController.text,
        )
      ],
    );

    Navigator.pop(context, newCompany);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Thêm công ty mới")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Tên công ty")),
            TextField(controller: _websiteController, decoration: InputDecoration(labelText: "Website")),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Mô tả")),
            Divider(),
            Text("Thông tin chi nhánh chính", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: _branchNameController, decoration: InputDecoration(labelText: "Tên chi nhánh")),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: "Địa chỉ")),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submit,
              child: Text("Lưu công ty"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
