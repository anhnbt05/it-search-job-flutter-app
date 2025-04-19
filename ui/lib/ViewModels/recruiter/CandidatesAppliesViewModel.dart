import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ui/Services/application_recruiter_service.dart';
import '../../ Constants/api_constants.dart';
import '../../Models/Applications.dart';
import '../../Models/Jobs.dart';
import '../../Services/job_service.dart';

class CandidatesAppliesViewModel extends ChangeNotifier {
  late Future<List<cJobs_recruiter?>> _jobsFuture;
  late Future<List<List<cApplications_recruiter>?>> _applicationsFuture;
  TextEditingController _rejectReason = new TextEditingController();

  List<cJobs_recruiter?> _jobs = [];
  List<List<cApplications_recruiter>?> _applications = [];

  set applications(List<List<cApplications_recruiter>?> value) {
    _applications = value;
  }

  Future<List<cJobs_recruiter?>> get jobsFuture => _jobsFuture;
  Future<List<List<cApplications_recruiter>?>> get applicationsFuture => _applicationsFuture;

  List<List<cApplications_recruiter>?> get applications => _applications;
  List<cJobs_recruiter?> get jobs => _jobs;


  set jobs(List<cJobs_recruiter?> value) {
    _jobs = value;
  }

  TextEditingController get rejectReason => _rejectReason;

  @override
  void dispose() {
    _rejectReason.dispose();
    super.dispose();
  }

  void initFutures() {
    _jobsFuture = JobService().getJobs(accessToken: APIConstants.token);

    _applicationsFuture = _jobsFuture.then((jobsF) async {

      jobs = jobsF;

      List<Future<List<cApplications_recruiter>?>> applicationFutures = jobsF.map((job) {
        return ApplicationService().getApplicationsList(
          accessToken: APIConstants.token,
          jobID: job!.ID.toString(),
        );
      }).toList();

      List<List<cApplications_recruiter>?> appList = await Future.wait(applicationFutures);

      applications = appList;

      notifyListeners();

      return appList;
    });
  }

  Future<void> approveApplication(String applicationId) async {
    final success = await ApplicationService().acceptApplication(
      accessToken: APIConstants.token,
      openApplicationIds: [applicationId],
    );
    if (success) {
      for (var appList in applications) {
        final index = appList?.indexWhere((app) => app.ID == applicationId);
        if (index != null && index >= 0) {
          appList![index] = appList[index].copyWith(status: 'accepted');
          break;
        }
      }
      notifyListeners();
    }
  }

  Future<bool> rejectApplication(
      {required String applicationId, required String reason}) async {
    final success = await ApplicationService().rejectApplication(
        accessToken: APIConstants.token,
        applicationId: applicationId,
        reason: reason);
    if (success) {
      for (var appList in applications) {
        final index = appList?.indexWhere((app) => app.ID == applicationId);
        if (index != null && index >= 0) {
          appList![index] = appList[index].copyWith(status: 'rejected');
          break;
        }
      }
      rejectReason.clear();
      notifyListeners();
      return true;
    }
    return false;
  }
}