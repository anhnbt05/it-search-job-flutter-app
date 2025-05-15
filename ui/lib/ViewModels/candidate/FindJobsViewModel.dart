import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ui/Models/Jobs.dart';

import '../../Constants/api_constants.dart';
import '../../Services/job_service.dart';

class FindJobsViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  final FlutterSecureStorage _storage = APIConstants.storage;

  List<cJobs_recruiter?> recommendedjobs = [];
  List<cJobs_recruiter?> _allJobs = [];
  List<cJobs_recruiter?> jobs = [];
  bool isLoading = false;
  bool hasFetched = false;
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
    if (hasFetched) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;

      final fetchedJobs = await _jobService.getJobs(accessToken: accessToken);
      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
      hasFetched = true;
    } catch (e) {
      error = "Đã xảy ra lỗi khi tải danh sách công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchJobsByLocation(String locationId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;
      final fetchedJobs = await _jobService.getJobsbyLocation(
        accessToken: accessToken,
        locationID: locationId,
      );
      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
    } catch (e) {
      error = "Đã xảy ra lỗi khi lọc theo địa điểm: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobsByCategory(String categoryName) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;
      final fetchedJobs = await _jobService.getJobsbyCategory(
        accessToken: accessToken,
        categoryName: categoryName,
      );
      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
    } catch (e) {
      error = "Đã xảy ra lỗi khi lọc theo ngành nghề: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterJobs(String query) {
    final q = query.toLowerCase().trim();
    jobs = _allJobs.where((job) {
      final title = job?.Title.toLowerCase() ?? '';
      return title.contains(q);
    }).toList();
    notifyListeners();
  }

  Future<void> addFavoriteJob(List<String> jobData) async {
    final accessToken = APIConstants.accessToken;

    final success = await _jobService.postFavoriteJob(
      accessToken: accessToken,
      jobData: jobData,
    );

    if (success) {
      notifyListeners();
    }
  }

  Future<void> removeFavoriteJob(List<String> jobId) async {
    final accessToken = APIConstants.accessToken;

    final success = await _jobService.deleteFavoriteJob(
      accessToken: accessToken,
      jobId: jobId,
    );

    if (success) {
      notifyListeners();
    }
  }
}

