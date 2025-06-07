import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Models/Categories.dart';

import '../Helpers/helpers.dart';
import '../Helpers/toastification.dart';
import '../Models/ResponseModel.dart';
import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, String>>?> getCategory({
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);

      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getCategories_endpoint,
        accessToken: validToken!,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched job categories.");
        List<dynamic>? data = jsonDecode(response.body);
        List<Map<String, String>> map = data!.map((e) => {e["ID"].toString(): e["CategoryName"].toString()}).toList();
        return map;
      } else {
        print("Failed to fetch job categories: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fetching job categories: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getCategory2({
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getCategories_endpoint,
        accessToken: validToken!,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched job categories.");
        final decoded = jsonDecode(response.body);
        print('Decoded response: $decoded');

        if (decoded is List) {
          final result = decoded.whereType<Map<String, dynamic>>().toList();
          print("Parsed ${result.length} categories.");
          return result;
        } else {
          print("Error: Expected a List but got ${decoded.runtimeType}");
          return null;
        }
      } else {
        print("API Error ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e, stackTrace) {
      print("Exception in getCategory2: $e\n$stackTrace");
      return null;
    }
  }

  Future<ResponseModel> addCategory({
    required BuildContext context,
    required String categoryName,
  }) async {
    final validToken = await getValidAccessToken(context);
    final url = Uri.parse('${APIConstants.baseUrl}/${APIConstants.postCategory_endpoint}');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $validToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'CategoryName': categoryName
      }),
    );
    if (response.statusCode == 201) {
      showSuccessToastification(title: "Hoàn tất", message: "Thêm danh mục thành công");
      List<cCategories> data = (jsonDecode(response.body) as List)
          .map((e) => cCategories.fromJson(e as Map<String, dynamic>))
          .toList();
      return ResponseModel(success: true, message: "Thêm danh mục thành công", messageList: ["Thêm danh mục thành công"], data: data);
    } else {
      showErrorToastification(title: "Lỗi", message: jsonDecode(response.body)["message"]);
      return ResponseModel(success: false, message: jsonDecode(response.body)["message"], messageList: [jsonDecode(response.body)["message"]], data: null);
    }
  }
}
