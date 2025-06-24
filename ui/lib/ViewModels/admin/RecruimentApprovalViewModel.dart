import 'package:flutter/material.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Services/job_service.dart';

class RecruiterApprovalViewModel extends ChangeNotifier {
  List<cJobs_recruiter?>? _jobs;
  List<cJobs_recruiter?>? get jobs => _jobs;
  BuildContext? context;

  RecruiterApprovalViewModel(BuildContext context) {
    loadJobs(context);
    this.context = context;
  }

  Future<void> loadJobs(BuildContext context) async {
    _jobs = await JobService().getJobs(context: context);
    notifyListeners();
  }

  Future<void> loadJobsWithoutContext() async {
    _jobs = await JobService().getJobs(context: context!);
    notifyListeners();
  }

}
