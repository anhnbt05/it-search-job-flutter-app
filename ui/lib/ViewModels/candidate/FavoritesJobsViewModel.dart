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

  Future<void> fetchFavoritesJobs(BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {

      jobs = await _jobService.getFavoritesJobs(
        context: context,
      );
    } catch (e) {
      error = "Đã xảy ra lỗi khi tải danh sách công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
