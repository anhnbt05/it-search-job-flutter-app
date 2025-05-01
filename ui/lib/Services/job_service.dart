import 'dart:convert';

import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/toastification.dart';
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
        var result = data?.map((e) => cJobs_recruiter.fromJson(e))
            .where((e) =>
        e.DeletedAt == null && e.ExpiredAt.isAfter(DateTime.now()))
            .toList() ?? [];
        result.sort((a, b) => b.PostedAt.compareTo(a.PostedAt));
        return result;
      } else {
        print("Failed to fetch jobs list: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<bool> deleteJob({
    required String accessToken,
    required String Id,
  }) async {
    try {
      final response = await _apiService.deleteJobWithToken(
          endpoint: APIConstants.deleteJob_endpoint,
          Id: Id,
          accessToken: accessToken);
      if (response.statusCode == 200) {
        print("Job deleted successfully.");
        showSuccessToastification(title: 'Xoá thành công', message: "Bài tuyển dụng đã được xóa");
        return true;
      } else {
        print("Failed to delete job: ${response.body}");
        showErrorToastification(title: 'Lối', message: jsonDecode(response.body)['message']);
        return false;
      }
    } catch (e) {
      print("Error deleting job: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
      return false;
    }
  }

  Future<cJobs?> getJobByID(
      {required String Id, required String accessToken}) async {
    try {
      final response = await _apiService.getWithToken(
          endpoint: '${APIConstants.getJob_endpoint}/$Id',
          accessToken: APIConstants.token);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print("Successfully fetched job.");
        var job = cJobs.fromJson(data);
        return job;
      } else {
        print("Failed to fetch job: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<bool> editJob({required String Id, required Map<String, dynamic> jobData, required String accessToken}) async {
    try {
      final response = await _apiService.patchWithToken(endpoint: APIConstants.patchJob_endpoint, body: jobData, accessToken: accessToken, Id: Id);
      if (response.statusCode == 200) {
        showSuccessToastification(title: 'Hoàn tất', message: "Nội dung bài tuyển dụng đã được cập nhật\nVui lòng chờ quản trị viên phê duyệt");
        return true;
      } else {
        print("Failed to edit job: ${response.body}");
        showErrorToastification(title: 'Lỗi', message: jsonDecode(response.body)['message']);
        return false;
      }
    } catch (e) {
      print("Error: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
      return false;
    }
  }
}

