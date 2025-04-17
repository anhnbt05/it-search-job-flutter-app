import 'dart:convert';
import 'package:ui/Models/Applications.dart';

import '../ Constants/api_constants.dart';
import 'api_service.dart';

class ApplicationService {
  final ApiService _apiService = ApiService();

  Future<List<cApplications_recruiter>?> getApplicationsList({
    required String accessToken,
    required String jobID,
  }) async {
    try {
      final response = await _apiService.getByIDWithToken2(
        endpoint1: APIConstants.getApplications_recruiter_endpoint1,
        id: jobID,
        endpoint2: APIConstants.getApplications_recruiter_endpoint2,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched applications list.");
        final List<dynamic> data = jsonDecode(response.body);
        final result = data.map((e) => cApplications_recruiter.fromJson(e)).toList();
        if (result.isEmpty) {return result;}
        result.sort((a, b) => b.AppliedAt.compareTo(a.AppliedAt));
        return result;
      } else {
        print("Failed to fetch applications list: ${response.body}");
        return null;
      }

    } catch (e) {
      print("Error fetching applications list: $e");
      return null;
    }
  }
}