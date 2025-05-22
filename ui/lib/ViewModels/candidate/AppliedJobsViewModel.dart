import 'package:flutter/material.dart';

import '../../Constants/api_constants.dart';
import '../../Models/Applications.dart';
import '../../Services/application_candidate_service.dart';

class AppliedJobWithDetail {
  final cApplications_candidate? application;
  final cApplications_candidate? detail;

  AppliedJobWithDetail({
    required this.application,
    this.detail,
  });
}

class AppliedJobsViewModel extends ChangeNotifier {
  final ApplicationCandidateService _service = ApplicationCandidateService();

  List<AppliedJobWithDetail> _appliedJobs = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppliedJobWithDetail> get appliedJobs => _appliedJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllAppliedJobsWithDetails() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final accessToken = APIConstants.accessToken;

      final applications = await _service.getApplicationsForCandidate(
        accessToken: accessToken,
      );

      if (applications == null) {
        _errorMessage = "Không thể lấy danh sách công việc đã ứng tuyển.";
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<AppliedJobWithDetail> combinedList = [];

      for (var app in applications) {
        final details = await _service.getDetailApplicationForCandidate(
          accessToken: accessToken,
          applicationID: app.ID,
        );

        final detail = details != null && details.isNotEmpty ? details.first : null;

        combinedList.add(
          AppliedJobWithDetail(
            application: app,
            detail: detail,
          ),
        );
      }

      _appliedJobs = combinedList;
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }
}
