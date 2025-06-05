import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Helpers/toastification.dart';

import 'api_service.dart';

class WorkExperiencesService {
  final ApiService _apiService = ApiService();
  Future<bool> postWorkExperience({
    required Map<String, dynamic> workExperienceDto,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      final response = await _apiService.postWithToken(
        accessToken: validToken!,
        endpoint: APIConstants.WorkExperiences_endpoint,
        body: workExperienceDto,
      );
      print(jsonEncode(workExperienceDto));
      if (response.statusCode == 201) {
        showSuccessToastification(
          title: "Thành công",
          message: "Đã thêm kinh nghiệm làm việc",
        );
        return true;
      } else {
        final error = jsonDecode(response.body);
        showErrorToastification(
          title: "Lỗi",
          message: error['message'] ?? "Thêm thất bại",
        );
        return false;
      }
    } catch (e) {
      showErrorToastification(title: "Lỗi", message: e.toString());
      return false;
    }
  }

  Future<bool> patchWorkExperience({
    required String workexperienceId,
    required Map<String, dynamic> workExperienceDto,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      final response = await _apiService.patchWithToken(
        endpoint: APIConstants.WorkExperiences_endpoint,
        body: workExperienceDto,
        accessToken: validToken!,
        Id: workexperienceId,
      );

      if (response.statusCode == 200) {
        showSuccessToastification(
          title: "Thành công",
          message: "Cập nhật kinh nghiệm làm việc thành công",
        );
        return true;
      } else {
        final error = jsonDecode(response.body);
        showErrorToastification(
          title: "Lỗi",
          message: error['message'] ?? "Cập nhật thất bại",
        );
        return false;
      }
    } catch (e) {
      showErrorToastification(title: "Lỗi", message: e.toString());
      return false;
    }
  }

  Future<bool> deleteWorkExperience({
    required String experienceId,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      final response = await _apiService.deleteJobWithToken(
        endpoint: APIConstants.WorkExperiences_endpoint,
        Id: experienceId,
        accessToken: validToken!,
      );

      if (response.statusCode == 200) {
        showSuccessToastification(
          title: "Thành công",
          message: "Đã xoá kinh nghiệm làm việc",
        );
        return true;
      } else {
        final error = jsonDecode(response.body);
        showErrorToastification(
          title: "Lỗi",
          message: error['message'] ?? "Xoá thất bại",
        );
        return false;
      }
    } catch (e) {
      showErrorToastification(title: "Lỗi", message: e.toString());
      return false;
    }
  }
}
