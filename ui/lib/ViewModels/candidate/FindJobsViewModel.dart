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
  Set<String> favoriteJobIds = {};
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

      // Đồng thời lấy danh sách favorite
      await fetchFavoriteJobs();

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

      // Cập nhật lại favorite sau lọc
      await fetchFavoriteJobs();
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

      // Cập nhật lại favorite sau lọc
      await fetchFavoriteJobs();
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

  bool isJobFavorited(String jobId) {
    return favoriteJobIds.contains(jobId);
  }

  Future<void> fetchFavoriteJobs() async {
    try {
      final accessToken = APIConstants.accessToken;
      final favoriteJobs = await _jobService.getFavoritesJobs(
        accessToken: accessToken,
      );
      favoriteJobIds = favoriteJobs.map((job) => job!.ID.toString()).toSet();
    } catch (e) {
      // không thông báo lỗi UI nếu fail phần này
      print("Lỗi khi lấy danh sách yêu thích: $e");
    }
  }

  Future<void> addFavoriteJob(String jobId) async {
    final accessToken = APIConstants.accessToken;

    final success = await _jobService.postFavoriteJob(
      accessToken: accessToken,
      jobId: jobId,
    );

    if (success) {
      favoriteJobIds.add(jobId);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteJob(String jobId) async {
    final accessToken = APIConstants.accessToken;

    final success = await _jobService.deleteFavoriteJob(
      accessToken: accessToken,
      jobIds: jobId,
    );

    if (success) {
      favoriteJobIds.remove(jobId);
      notifyListeners();
    }
  }
}
