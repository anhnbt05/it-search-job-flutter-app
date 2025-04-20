import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ Constants/api_constants.dart';
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
      final response =
      await http.get(Uri.parse("$_baseUrl/auth/companies/$companyId/branches"));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<cCompanyLocations> branches =
        jsonData.map((item) => cCompanyLocations.fromJson(item)).toList();

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
}
