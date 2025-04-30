import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Constants/api_constants.dart';
import '../Models/Companies.dart';
import '../Models/CompanyLocations.dart';
import '../Models/ResponseModel.dart';

class AuthCompaniesService {
  final String _baseUrl = APIConstants.baseUrl;

  Future<ResponseModel> companies() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/auth/companies"));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<cCompanies> companyList =
        jsonData.map((item) => cCompanies.fromJson(item)).toList();
        return ResponseModel(
          success: true,
          message: "Thành công",
          messageList: ["Thành công"],
          data: companyList,
        );
      } else {
        return ResponseModel(
          success: false,
          message: "Lỗi server: ${response.statusCode}",
          messageList: ["Lỗi server: ${response.statusCode}"],
        );
      }
    } catch (e) {
      return ResponseModel(
        success: false,
        message: "Lỗi kết nối: $e",
        messageList: ["Lỗi kết nối: $e"],
      );
    }
  }

  Future<ResponseModel> fetchBranches(String companyId) async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/auth/companies/$companyId/branches"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<cCompanyLocations> branches = jsonData
            .map((item) => cCompanyLocations.fromJson(item))
            .toList();
        return ResponseModel(
          success: true,
          message: "Thành công",
          messageList: ["Thành công"],
          data: branches,
        );
      } else {
        return ResponseModel(
          success: false,
          message: "Lỗi server: ${response.statusCode}",
          messageList: ["Lỗi server: ${response.statusCode}"],
        );
      }
    } catch (e) {
      return ResponseModel(
        success: false,
        message: "Lỗi kết nối: $e",
        messageList: ["Lỗi kết nối: $e"],
      );
    }
  }

  Future<ResponseModel> addBranch({
    required String companyId,
    required String branchName,
    required String address,
    required String locationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/companies/$companyId/branches"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "BranchName": branchName,
          "Address": address,
          "LocationID": locationId,
        }),
      );
      final dynamic decoded = json.decode(response.body);
      return ResponseModel.fromJson(decoded);
    } catch (e) {
      return ResponseModel(
        success: false,
        message: "Lỗi kết nối: \$e",
        messageList: ["Lỗi kết nối: \$e"],
      );
    }
  }

  /// Tạo công ty mới cùng chi nhánh chính
  Future<ResponseModel> addCompany({
    required String name,
    required String websiteUrl,
    required String description,
    required String branchName,
    required String address,
    required String locationId,
  }) async {
    try {
      final uri = Uri.parse("$_baseUrl/auth/companies");
      final payload = {
        "Name": name,
        "WebsiteUrl": websiteUrl,
        "Description": description,
        "createCompanyLocationDto": {
          "BranchName": branchName,
          "Address": address,
          "LocationID": locationId,
        },
      };
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      final dynamic decoded = json.decode(response.body);
      return ResponseModel.fromJson(decoded);
    } catch (e) {
      return ResponseModel(
        success: false,
        message: "Lỗi kết nối: $e",
        messageList: ["Lỗi kết nối: $e"],
      );
    }
  }
}
