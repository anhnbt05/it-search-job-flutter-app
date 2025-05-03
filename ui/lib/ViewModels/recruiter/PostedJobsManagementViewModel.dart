import 'package:flutter/widgets.dart';
import 'package:toastification/toastification.dart';
import 'package:ui/Models/Recruiters.dart';
import 'package:ui/Services/user_service.dart';

import '../../Constants/api_constants.dart';
import '../../Models/Jobs.dart';
import '../../Services/job_service.dart';

class PostedJobsManagementViewModel extends ChangeNotifier {
  late final String userId;
  late Future<List<cJobs_recruiter?>> _jobsFuture;
  List<cJobs_recruiter?> _jobs_open = [];
  List<cJobs_recruiter?> _jobs_closed = [];
  List<cJobs_recruiter?> _jobs_pending = [];
  List<cJobs_recruiter?> _jobs_rejected = [];
  List<cJobs_recruiter?> _jobs = [];
  late Future<cRecruiters?> _recruiterFuture;
  cRecruiters? _recruiterInfo;
  String _statusFilter = "all";

  Future<List<cJobs_recruiter?>> get jobsFuture => _jobsFuture;
  List<cJobs_recruiter?> get jobs_open => _jobs_open;
  List<cJobs_recruiter?> get jobs_closed => _jobs_closed;
  List<cJobs_recruiter?> get jobs_pending => _jobs_pending;
  List<cJobs_recruiter?> get jobs_rejected => _jobs_rejected;
  List<cJobs_recruiter?> get jobs => _jobs;

  set jobs(List<cJobs_recruiter?> value) {
    _jobs = value;
  }

  Future<cRecruiters?> get recruiter => _recruiterFuture;

  String get statusFilter => _statusFilter;

  cRecruiters? get recruiterInfo => _recruiterInfo;

  void Filter(String? value) {
    _statusFilter = value!;
    if (value == "all") {
      _jobs = (_jobs_open + _jobs_closed + _jobs_pending + _jobs_rejected);
    } else if (value == "open") {
      _jobs = _jobs_open;
    } else if (value == "pending") {
      _jobs = _jobs_pending;
    } else if (value == 'closed_rejected') {
      _jobs = _jobs_closed + _jobs_rejected;
    }
    _jobs.sort((a,b) => b!.PostedAt.compareTo(a!.PostedAt));
    notifyListeners();
  }

  bool isLoaded = false;
  late Future<void> loadFuture;

  PostedJobsManagementViewModel(this.userId) {
    loadFuture = initFutures().then((_) {
      isLoaded = true;
      notifyListeners();
    });
  }

  Future<void> initFutures() async {
    _jobsFuture = JobService().getJobs(accessToken: APIConstants.accessToken).then((value) {
      _jobs = value.map((e) => e).toList();
      _jobs.sort((a,b) => b!.PostedAt.compareTo(a!.PostedAt));

      _jobs_open = value.where((element) => element!.Status == 'open').toList();
      _jobs_pending = value.where((element) => element!.Status == 'pending').toList();
      _jobs_closed = value.where((element) => element!.Status == 'closed').toList();
      _jobs_rejected = value.where((element) => element!.Status == 'rejected').toList();
      return value;
    });

    _recruiterFuture = UserService().getRecruiterInfo(Id: userId, accessToken: APIConstants.accessToken).then((value) => _recruiterInfo = value);

    await Future.wait([_jobsFuture, _recruiterFuture]);
  }

  Future<void> deleteJob({required String Id}) async {
    final success = await JobService().deleteJob(accessToken: APIConstants.accessToken, Id: Id);
    if (success) {
      cJobs_recruiter? job = _jobs.firstWhere((e) => e!.ID == Id);
      if (job != null) {
        if (job.Status == 'pending') _jobs_pending.removeWhere((e) => e!.ID == Id);
        else if (job.Status == 'closed') _jobs_closed.removeWhere((e) => e!.ID == Id);
        else if (job.Status == 'rejected') _jobs_rejected.removeWhere((e) => e!.ID == Id);
      }
      _jobs.removeWhere((element) => element!.ID == Id);
      notifyListeners();
    }
  }
}