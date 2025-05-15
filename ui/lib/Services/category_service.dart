import 'dart:convert';

import 'package:ui/Constants/api_constants.dart';

import 'api_service.dart';

class CategoryService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, String>>?> getCategory({
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getCategories_endpoint,
        accessToken: accessToken,
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
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getCategories_endpoint,
        accessToken: accessToken,
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



}
