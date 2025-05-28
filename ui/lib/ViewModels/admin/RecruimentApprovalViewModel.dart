import 'package:flutter/material.dart';
import 'package:ui/Models/Jobs.dart';
import 'package:ui/Services/job_service.dart';

class RecruiterApprovalViewModel extends ChangeNotifier {
  List<cJobs_recruiter?>? _jobs;
  late final Future<List<cJobs_recruiter?>>? _jobsFuture;
  Future<List<cJobs_recruiter?>>? get jobsFuture => _jobsFuture;
  List<cJobs_recruiter?>? get jobs => _jobs;

  RecruiterApprovalViewModel(BuildContext context) {
    _jobsFuture = JobService().getJobs(context: context).then((jobsF) {
      _jobs = jobsF;
      return jobsF;
    });
  }
}