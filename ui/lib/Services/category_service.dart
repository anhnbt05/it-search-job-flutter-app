import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:ui/Constants/api_constants.dart';

import '../Helpers/helpers.dart';
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
}
