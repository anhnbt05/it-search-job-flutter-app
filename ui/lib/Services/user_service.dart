import 'dart:convert';

import 'package:ui/Constants/api_constants.dart';

import '../Models/Recruiters.dart';
import 'api_service.dart';


// temporary
class UserService {
  final ApiService _apiService = ApiService();

  Future<cRecruiters?> getRecruiterInfo(
      {required String Id, required String accessToken}) async {
    try {
      final response = await _apiService.getWithToken(
        accessToken: accessToken,
        endpoint: '${APIConstants.getUser_endpoint}/$Id',);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        return cRecruiters.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}