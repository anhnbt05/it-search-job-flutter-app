import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:ui/Helpers/helpers.dart';
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

  Future<void> fetchRecommendedJobs(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final candidateId = await _storage.read(key: 'candidateID');


      recommendedjobs = await _jobService.getRecommendedJobs(
        context: context,
        candidateID: candidateId!,
      );
    } catch (e) {
      error = "Đã xảy ra lỗi khi tải danh sách công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavoriteJobs(BuildContext context) async {
    try {
      final favoriteJobs = await _jobService.getFavoritesJobs(
        context: context,
      );
      favoriteJobIds = favoriteJobs.map((job) => job.Job!.ID.toString()).toSet();
      print("Favorite Job IDs loaded: $favoriteJobIds");
      notifyListeners();
    } catch (e) {
      print("Lỗi khi lấy danh sách yêu thích: $e");
    }
  }


  Future<void> fetchJobs(BuildContext context) async {
    if (hasFetched) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetchedJobs = await _jobService.getJobs(context: context);
      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
      await fetchFavoriteJobs(context);
      hasFetched = true;


    } catch (e) {
      error = "Đã xảy ra lỗi khi tải danh sách công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobsByLocation(String locationId, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetchedJobs = await _jobService.getJobsbyLocation(
        locationID: locationId,
        context: context,
      );
      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
      await fetchFavoriteJobs(context);
    } catch (e) {
      error = "Đã xảy ra lỗi khi lọc theo địa điểm: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobsByCategory(List<String> categoryNames, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetchedJobs = await _jobService.getJobsbyCategories(
        categoryNames: categoryNames,
        context: context,
      );

      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
      await fetchFavoriteJobs(context);

    } catch (e) {
      error = "Đã xảy ra lỗi khi lọc theo ngành nghề: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchJobsByBothLocationCategory(String locationId, List<String> categoryNames, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final fetchedJobs = await _jobService.getJobsBothLocationCategory(
        locationID: locationId,
        categoryNames: categoryNames,
        context: context,
      );

      _allJobs = fetchedJobs;
      jobs = fetchedJobs;
      await fetchFavoriteJobs(context);

    } catch (e) {
      error = "Đã xảy ra lỗi khi lọc theo cả địa điểm và ngành nghề: $e";
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

  Future<void> addFavoriteJob(String jobId, BuildContext context) async {

    final success = await _jobService.postFavoriteJob(
      jobId: jobId,
      context: context,
    );

    if (success) {
      favoriteJobIds.add(jobId);
      notifyListeners();
    }
  }

  Future<void> removeFavoriteJob(String jobId, BuildContext context) async {

    final success = await _jobService.deleteFavoriteJob(
      jobId: jobId,
      context: context,
    );

    if (success) {
      favoriteJobIds.remove(jobId);
      notifyListeners();
    }
  }
}
