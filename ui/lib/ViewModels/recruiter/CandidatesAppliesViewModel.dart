import 'dart:async';
import 'dart:io';

import 'package:fl_downloader/fl_downloader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui/Services/application_recruiter_service.dart';
import 'package:ui/ViewModels/recruiter/PostedJobsManagementViewModel.dart';
import '../../Constants/api_constants.dart';
import '../../Models/Applications.dart';
import '../../Models/Jobs.dart';
import '../../Services/job_service.dart';

class CandidatesAppliesViewModel extends ChangeNotifier {
  final PostedJobsManagementViewModel postedJobsManagementViewModel;
  late Future<List<List<cApplications_recruiter>?>>? _applicationsFuture;
  TextEditingController _rejectReason = new TextEditingController();

  List<cJobs_recruiter?>? _jobs;
  List<List<cApplications_recruiter>?>? _applications;

  set applications(List<List<cApplications_recruiter>?>? value) {
    _applications = value;
  }

  Future<List<List<cApplications_recruiter>?>>? get applicationsFuture => _applicationsFuture;

  List<List<cApplications_recruiter>?>? get applications => _applications;
  List<cJobs_recruiter?>? get jobs => _jobs;


  set jobs(List<cJobs_recruiter?>? value) {
    _jobs = value;
  }

  TextEditingController get rejectReason => _rejectReason;

  @override
  void dispose() {
    _rejectReason.dispose();
    super.dispose();
  }

  bool isLoad = false;
  late final Future<void> loadFuture;


  CandidatesAppliesViewModel({required this.postedJobsManagementViewModel}) {
    if (postedJobsManagementViewModel.isLoaded) {
      initFutures();
    } else {
      postedJobsManagementViewModel.loadFuture.then((_) {
        initFutures();
      });
    }
  }

  void initFutures() {
    _jobs = postedJobsManagementViewModel.jobs_open;
    print(postedJobsManagementViewModel.jobs_open.length);
    List<Future<List<cApplications_recruiter>?>> applicationFutures = jobs!.map((job) {
      return ApplicationService().getApplicationsList(
        accessToken: APIConstants.accessToken,
        jobID: job!.ID.toString(),
      );
    }).toList();

    _applicationsFuture = Future.wait(applicationFutures).then((appList) {
      applications = appList;
      notifyListeners();
      return appList;
    });

    if (isLoad == false) isLoad = true;
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
      accessToken: APIConstants.accessToken,
      openApplicationIds: [applicationId],
    );
    if (success) {
      for (var appList in applications!) {
        final index = appList?.indexWhere((app) => app.ID == applicationId);
        if (index != null && index >= 0) {
          appList![index] = appList[index].copyWith(status: 'accepted');
          final jobId = appList[index].JobID;
          int jobIdx = jobs!.indexWhere((job) => job!.ID == jobId);
          final acceptedCount = appList.where((e) => e.Status == "accepted").length;

          if (jobIdx >= 0 && jobs![jobIdx] != null && acceptedCount == jobs![jobIdx]!.Vacancies) {
            int i = postedJobsManagementViewModel.jobs_open.indexWhere((e) => e!.ID == jobId);
            if (i >= 0) {
              final closedJob = postedJobsManagementViewModel.jobs_open[i]!.copyWith(status: 'closed');
              postedJobsManagementViewModel.jobs_closed.add(closedJob);
              postedJobsManagementViewModel.jobs_open.removeAt(i);
            }
            jobs!.removeWhere((e) => e!.ID == jobId);
            applications!.remove(appList);
            postedJobsManagementViewModel.Filter(postedJobsManagementViewModel.statusFilter);
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
        accessToken: APIConstants.accessToken,
        applicationId: applicationId,
        reason: reason);
    if (success) {
      for (var appList in applications!) {
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