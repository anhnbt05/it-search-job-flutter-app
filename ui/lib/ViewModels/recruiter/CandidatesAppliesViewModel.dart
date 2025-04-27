import 'dart:async';
import 'dart:io';

import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui/Services/application_recruiter_service.dart';
import '../../Constants/api_constants.dart';
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

      jobs = jobsF.where((e) => e!.Status == 'open').toList();

      List<Future<List<cApplications_recruiter>?>> applicationFutures = jobs.map((job) {
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

  DownloadViewModel() {
    _initialize();
  }

  void _initialize() {
    FlDownloader.initialize();
  }

  Future<bool> isFileExist(String url, {String? fileName}) async {
    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }
    final filePath = '${downloadsDir.path}/$fileName';
    final file = File(filePath);
    if (file.existsSync()) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> startDownload(String url, {String? fileName}) async {
    await FlDownloader.download(url, fileName: fileName);
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
          int jobIdx = jobs.indexWhere((job) => job!.ID == appList[index].JobID);
          final acceptedCount = appList.where((e) => e.Status == "accepted").length;
          if (jobs[jobIdx] != null && acceptedCount == jobs[jobIdx]!.Vacancies) {
            jobs.removeWhere((e) => e!.ID == jobs[jobIdx]!.ID);
            applications.remove(appList);
          }
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