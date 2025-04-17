import 'dart:convert';

import 'package:ui/%20Constants/api_constants.dart';
import 'api_service.dart';
import 'package:ui/Models/Jobs.dart';

class JobService {
  final ApiService _apiService = ApiService();

  Future<bool> postJob({
    required String accessToken,
    required Map<String, dynamic> jobData,
  }) async {
    try {
      final response = await _apiService.postWithToken(
        endpoint: APIConstants.postJob_endpoint,
        body: jobData,
        accessToken: accessToken,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Job posted successfully.");
        return true;
      } else {
        print("Failed to post job: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error posting job: $e");
      return false;
    }
  }
  Future<List<cJobs_recruiter?>> getJobs({
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getJob_endpoint,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched jobs list.");
        List<dynamic>? data = jsonDecode(response.body);
        var result = data?.map((e) => cJobs_recruiter.fromJson(e)).toList() ?? [];
        result.sort((a, b) => b.PostedAt.compareTo(a.PostedAt));
        return result;
      } else {
        print("Failed to fetch jobs list: ${response.body}");
        return [];
      }
    } catch(e) {
      print("Error: $e");
      return [];
    }
  }
}

