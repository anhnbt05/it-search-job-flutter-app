import 'package:flutter/widgets.dart';
import 'package:ui/Models/Recruiters.dart';
import 'package:ui/Services/user_service.dart';

import '../../Constants/api_constants.dart';
import '../../Models/Jobs.dart';
import '../../Services/job_service.dart';

class PostedJobsManagementViewModel extends ChangeNotifier {
  late Future<List<cJobs_recruiter?>> _jobsFuture;
  List<cJobs_recruiter?> _jobs_open = [];
  List<cJobs_recruiter?> _jobs_close = [];
  List<cJobs_recruiter?> _jobs_pending = [];
  late Future<cRecruiters?> _recruiterFuture;
  cRecruiters? _recruiterInfo = null;
  String _statusFilter = "all";

  Future<List<cJobs_recruiter?>> get jobsFuture => _jobsFuture;
  List<cJobs_recruiter?> get jobs_open => _jobs_open;
  List<cJobs_recruiter?> get jobs_close => _jobs_close;
  List<cJobs_recruiter?> get jobs_pending => _jobs_pending;
  Future<cRecruiters?> get recruiter => _recruiterFuture;

  String get statusFilter => _statusFilter;

  cRecruiters? get recruiterInfo => _recruiterInfo;

  void setStatusFilter(String? value) {
    _statusFilter = value!;
    notifyListeners();
  }

  void initFutures() {
    _jobsFuture = JobService().getJobs(accessToken: APIConstants.token).then((value) {
      _jobs_open = value.where((element) => element!.Status == 'open').toList();
      _jobs_close = value.where((element) => element!.Status == 'closed').toList();
      _jobs_pending = value.where((element) => element!.Status == 'pending').toList();
      return value;
    });

    _recruiterFuture = UserService().getRecruiterInfo(Id: APIConstants.userId, accessToken: APIConstants.token).then((value) => _recruiterInfo = value);
  }
}