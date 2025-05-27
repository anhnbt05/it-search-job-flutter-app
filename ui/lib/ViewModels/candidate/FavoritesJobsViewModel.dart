import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ui/Models/Jobs.dart';

import '../../Constants/api_constants.dart';
import '../../Models/JobFavorites.dart';
import '../../Services/job_service.dart';

class FavoritesJobsViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  List<cJobFavorites?> jobs = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchFavoritesJobs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;

      jobs = await _jobService.getFavoritesJobs(
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
