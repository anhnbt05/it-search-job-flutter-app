import 'package:flutter/material.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Services/job_service.dart';

class FindJobsViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  List<cJobs_recruiter?> jobs = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchJobs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      jobs = await _jobService.getJobs(accessToken: APIConstants.accessToken);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
