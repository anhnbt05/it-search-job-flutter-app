import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ui/Models/Jobs.dart';

import '../../Constants/api_constants.dart';
import '../../Services/job_service.dart';

class FindJobsViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  final FlutterSecureStorage _storage = APIConstants.storage;

  List<cJobs?> recommendedjobs = [];
  List<cJobs_recruiter?> jobs = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchRecommendedJobs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userId = await _storage.read(key: 'userID');
      final accessToken = APIConstants.accessToken;

      if (userId == null) {
        error = "Không tìm thấy userID";
        isLoading = false;
        notifyListeners();
        return;
      }

      recommendedjobs = await _jobService.getRecommendedJobs(
        accessToken: accessToken,
        candidateID: userId,
      );
    } catch (e) {
      error = "Đã xảy ra lỗi khi tải danh sách công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchJobs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;

      jobs = await _jobService.getJobs(
        accessToken: accessToken,
      );
    } catch (e) {
      error = "Đã xảy ra lỗi khi tải danh sách công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
