import 'package:flutter/material.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Services/job_service.dart';
import 'package:ui/Constants/api_constants.dart';

class DetailJobViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  bool isLoading = false;
  String? error;
  cJobs? jobDetail;

  Future<void> fetchJobDetail(String jobId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;

      jobDetail = await _jobService.getDetailJobs(
        jobId: jobId,
        accessToken: accessToken,
      );

      if (jobDetail == null) {
        error = "Không thể lấy chi tiết công việc.";
      }
    } catch (e) {
      error = "Đã xảy ra lỗi khi tải thông tin công việc: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
