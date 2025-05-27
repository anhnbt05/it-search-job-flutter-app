import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/toastification.dart';
import '../Models/JobFavorites.dart';
import 'api_service.dart';
import 'package:ui/Models/Jobs.dart';

class JobService {
  final ApiService _apiService = ApiService();

  Future<cJobs_recruiter?> postJob({
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
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> jobs = (data).cast<Map<String, dynamic>>();
        jobs.sort((a, b) =>
            DateTime.parse(b['PostedAt']).compareTo(DateTime.parse(a['PostedAt'])));
        var latestJob = jobs.isNotEmpty ? jobs.first : null;
        var job = (latestJob == null) ? null : cJobs_recruiter.fromJson(latestJob);
        showSuccessToastification(title: 'Thành công', message: 'Bài đăng của bạn đã được gửi đền quản trị viên để chờ duyệt');
        return job;
      } else {
        print("Failed to post job: ${response.body}");
        showErrorToastification(title: 'Lỗi', message: jsonDecode(response.body)['message']);
        return null;
      }
    } catch (e) {
      print("Error posting job: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
      return null;
    }
  }

  Future<bool> postFavoriteJob({
    required String accessToken,
    required String jobId,
  }) async {
    try {
      final body = {'jobIds': [jobId]};

      print("Sending body: ${jsonEncode(body)}");

      final response = await _apiService.postWithToken(
        endpoint: APIConstants.FavoritesJobs_endpoint,
        body: body,
        accessToken: accessToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSuccessToastification(
          title: 'Thành công',
          message: 'Đã thêm vào danh sách yêu thích',
        );
        return true;
      } else {
        print("Lỗi server: ${response.body}");
        final errorMessage = jsonDecode(response.body)['message'];
        showErrorToastification(
          title: 'Lỗi',
          message: errorMessage.toString(),
        );
        return false;
      }
    } catch (e) {
      print("Lỗi Exception: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
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
  Future<List<cJobFavorites>> getFavoritesJobs({
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.FavoritesJobs_endpoint,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched favorite jobs list.");
        List<dynamic>? data = jsonDecode(response.body);

        List<cJobFavorites> result = data?.map((e) => cJobFavorites.fromJson(e))
            .where((e) =>
        e.DeletedAt == null &&
            e.Job != null &&
            e.Job!.ExpiredAt != null &&
            e.Job!.ExpiredAt!.isAfter(DateTime.now()))
            .toList() ??
            [];

        result.sort((a, b) =>
            b.Job!.PostedAt!.compareTo(a.Job!.PostedAt!));

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


  Future<List<cJobs_recruiter?>> getRecommendedJobs({
    required String accessToken,
    required String candidateID,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getRecommendedJobs_candidate_endpoint(candidateID),
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched recommended full jobs list.");
        List<dynamic>? data = jsonDecode(response.body);

        var result = data
            ?.map((e) => cJobs_recruiter.fromJson(e))
            .where((e) =>
        e.DeletedAt == null && e.ExpiredAt.isAfter(DateTime.now()))
            .toList() ??
            [];

        result.sort((a, b) => b.PostedAt.compareTo(a.PostedAt));
        return result;
      } else {
        print("Failed to fetch full jobs list: ${response.body}");
        final errorMessage = jsonDecode(response.body)['message'];
        showErrorToastification(
          title: 'Lỗi',
          message: errorMessage.toString(),
        );
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
  Future<List<cJobs_recruiter?>> getJobsbyLocation({
    required String accessToken,
    required String locationID,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getJobsbyLocations_endpoint(locationID),
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched full jobs by location list.");
        List<dynamic>? data = jsonDecode(response.body);

        var result = data
            ?.map((e) => cJobs_recruiter.fromJson(e))
            .where((e) =>
        e.DeletedAt == null && e.ExpiredAt.isAfter(DateTime.now()))
            .toList() ??
            [];

        result.sort((a, b) => b.PostedAt.compareTo(a.PostedAt));
        return result;
      } else {
        print("Failed to fetch full jobs list: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
  Future<List<cJobs_recruiter?>> getJobsbyCategory({
    required String accessToken,
    required String categoryName,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getJobsbyCategories_endpoint(categoryName),
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Successfully fetched full jobs by category list.");
        List<dynamic>? data = jsonDecode(response.body);

        var result = data
            ?.map((e) => cJobs_recruiter.fromJson(e))
            .where((e) =>
        e.DeletedAt == null && e.ExpiredAt.isAfter(DateTime.now()))
            .toList() ??
            [];

        result.sort((a, b) => b.PostedAt.compareTo(a.PostedAt));
        return result;
      } else {
        print("Failed to fetch full jobs list: ${response.body}");
        return [];
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }


  Future<cJobs?> getDetailJobs({
    required String jobId,
    required String accessToken,
  }) async {
    try {
      final response = await _apiService.getWithToken(
        endpoint: APIConstants.getDetailJob_candidate_endpoint(jobId),
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final job = cJobs.fromJson(data);

        if (job.DeletedAt == null && job.ExpiredAt.isAfter(DateTime.now())) {
          return job;
        } else {
          print("Job đã hết hạn hoặc bị xoá");
          return null;
        }
      } else {
        print("Không lấy được chi tiết job: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi khi lấy chi tiết job: $e");
      return null;
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

  Future<bool> deleteFavoriteJob({
    required String accessToken,
    required String jobId,
  }) async {
    final body = {'jobIds': [jobId]};
    try {
      final response = await _apiService.deleteFavoriteJobWithToken(
        endpoint: APIConstants.FavoritesJobs_endpoint,
        body: body,
        accessToken: accessToken,
      );

      if (response.statusCode == 200) {
        print("Job removed from favorites successfully.");
        showSuccessToastification(
          title: 'Thành công',
          message: 'Đã xoá khỏi danh sách yêu thích',
        );
        return true;
      } else {
        print("Failed to remove job from favorites: ${response.body}");
        showErrorToastification(
          title: 'Lỗi',
          message: jsonDecode(response.body)['message'] ?? 'Xóa không thành công',
        );
        return false;
      }
    } catch (e) {
      print("Error removing favorite job: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
      return false;
    }
  }

  Future<cJobs?> getJobByID(
      {required String Id, required String accessToken}) async {
    try {
      final response = await _apiService.getWithToken(
          endpoint: '${APIConstants.getJob_endpoint}/$Id',
          accessToken: accessToken);
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

