import 'package:ui/%20Constants/api_constants.dart';

import 'api_service.dart';

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
}
