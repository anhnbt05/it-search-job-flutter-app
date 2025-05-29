import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Models/Applications.dart';

import '../Constants/api_constants.dart';
import '../Helpers/helpers.dart';
import 'api_service.dart';

class ApplicationService {
  final ApiService _apiService = ApiService();

  Future<List<cApplications_recruiter>?> getApplicationsList({
    required String jobID,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);

      final response = await _apiService.getByIDWithToken2(
        endpoint1: APIConstants.getApplications_recruiter_endpoint1,
        id: jobID,
        endpoint2: APIConstants.getApplications_recruiter_endpoint2,
        accessToken: validToken!,
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

  Future<bool> acceptApplication({
    required List<String> openApplicationIds,
    required BuildContext context,
  }) async {
    final validToken = await getValidAccessToken(context);

    try {
      final response = await _apiService.acceptApplicationsWithToken(
        endpoint: APIConstants.responseJobApplication_endpoint,
        body: {"acceptedApplicationIds" : openApplicationIds},
        accessToken: validToken!,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var data = jsonDecode(response.body);
        showSuccessToastification(message: data['message'], title: "Hoàn tất");
        return true;
      } else {
        var data = jsonDecode(response.body);
        showErrorToastification(message: data['message'], title: "Lỗi");
        return false;
      }
    } catch (e) {
      showErrorToastification(message: e.toString(), title: "Lỗi");
      return false;
    }
  }

  Future<bool> rejectApplication({
    required String applicationId,
    required String reason,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);

      final response = await _apiService.rejectApplicationsWithToken(
        endpoint: APIConstants.responseJobApplication_endpoint,
        body: {
          "rejectedApplications": [
            {
              "applicationId": applicationId,
              "reason": reason
            }
          ]
        },
        accessToken: validToken!,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var data = jsonDecode(response.body);
        showSuccessToastification(message: data['message'], title: "Hoàn tất");
        return true;
      }
      else {
        var data = jsonDecode(response.body);
        showErrorToastification(message: data['message'], title: "Lỗi");
        return false;
      }
    } catch (e) {
      showErrorToastification(message: e.toString(), title: "Lỗi");
      return false;
    }
  }
}