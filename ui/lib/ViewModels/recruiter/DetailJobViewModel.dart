import 'package:flutter/material.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Services/job_service.dart';

class DetailJobViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  bool isLoading = false;
  String? error;
  cJobs? jobDetail;

  Future<void> fetchJobDetail(String jobId, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {

      jobDetail = await _jobService.getDetailJobs(
        jobId: jobId,
        context: context,
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
