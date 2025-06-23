import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Helpers/toastification.dart';

import 'api_service.dart';

class WorkExperiencesService {
  final ApiService _apiService = ApiService();

  Future<bool> postWorkExperience({
    required String companyName,
    required String position,
    required String startDate,
    required String? endDate,
    required String descriptions,
    required String location,
    required String jobType,
    required File? logoFile,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${APIConstants.baseUrl}/${APIConstants.WorkExperiences_endpoint}'),
      );

      request.fields['CompanyName'] = companyName;
      request.fields['Position'] = position;
      request.fields['StartDate'] = startDate;
      if (endDate != null) request.fields['EndDate'] = endDate;
      request.fields['Descriptions'] = descriptions;
      request.fields['Location'] = location;
      request.fields['JobType'] = jobType;

      if (logoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logoFile',
            logoFile.path,
            contentType: MediaType('image', '*'),
          ),
        );
      }

      request.headers['Authorization'] = 'Bearer $validToken';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        showSuccessToastification(
          title: "Thành công",
          message: "Đã thêm kinh nghiệm làm việc",
        );
        return true;
      } else {
        final error = jsonDecode(responseBody);
        String errorMessage = 'Thêm kinh nghiệm thất bại';
        if (error['message'] is String) {
          errorMessage = error['message'];
        } else if (error['message'] is List) {
          errorMessage = error['message'][0]['message'] ?? errorMessage;
        }

        showErrorToastification(
          title: "Lỗi",
          message: errorMessage,
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
    required String companyName,
    required String position,
    required String startDate,
    required String? endDate,
    required String descriptions,
    required String location,
    required String jobType,
    required File? logoFile,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${APIConstants.baseUrl}/${APIConstants.WorkExperiences_endpoint}/$workexperienceId'),
      );

      request.fields['CompanyName'] = companyName;
      request.fields['Position'] = position;
      request.fields['StartDate'] = startDate;
      if (endDate != null) request.fields['EndDate'] = endDate;
      request.fields['Descriptions'] = jsonEncode(descriptions.split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList());
      request.fields['Location'] = location;
      request.fields['JobType'] = jobType;

      if (logoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logoFile',
            logoFile.path,
            contentType: MediaType('image', '*'),
          ),
        );
      }

      request.headers['Authorization'] = 'Bearer $validToken';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        showSuccessToastification(
          title: "Thành công",
          message: "Cập nhật kinh nghiệm làm việc thành công",
        );
        return true;
      } else {
        final error = jsonDecode(responseBody);
        String errorMessage = 'Cập nhật kinh nghiệm thất bại';
        if (error['message'] is String) {
          errorMessage = error['message'];
        } else if (error['message'] is List) {
          errorMessage = error['message'][0]['message'] ?? errorMessage;
        }

        showErrorToastification(
          title: "Lỗi",
          message: errorMessage,
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
        String errorMessage = 'Xoá kinh nghiệm thất bại';
        if (error['message'] is String) {
          errorMessage = error['message'];
        } else if (error['message'] is List) {
          errorMessage = error['message'][0]['message'] ?? errorMessage;
        }

        showErrorToastification(
          title: "Lỗi",
          message: errorMessage,
        );
        return false;
      }
    } catch (e) {
      showErrorToastification(title: "Lỗi", message: e.toString());
      return false;
    }
  }
}