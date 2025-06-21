import 'package:flutter/material.dart';

import '../../Models/Applications.dart';
import '../../Services/application_candidate_service.dart';

class AppliedJobWithDetail {
  final cApplications_candidate application;

  AppliedJobWithDetail({
    required this.application,
  });
}

class AppliedJobsViewModel extends ChangeNotifier {
  final ApplicationCandidateService _service = ApplicationCandidateService();

  List<AppliedJobWithDetail> _appliedJobs = [];
  List<AppliedJobWithDetail> _filteredJobs = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _statusFilter = 'all';

  List<AppliedJobWithDetail> get appliedJobs => _appliedJobs;
  List<AppliedJobWithDetail> get filteredJobs => _filteredJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get statusFilter => _statusFilter;

  Future<void> fetchAllAppliedJobs(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final applications = await _service.getApplicationsForCandidate(
        context: context,
      );

      if (applications == null) {
        _errorMessage = "Không thể lấy danh sách công việc đã ứng tuyển.";
      } else {
        _appliedJobs = applications
            .map((app) => AppliedJobWithDetail(application: app))
            .toList();
        _filteredJobs = _appliedJobs;
      }
    } catch (e) {
      _errorMessage = "Lỗi khi tải dữ liệu: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterByStatus(String status) {
    _statusFilter = status;

    if (status == 'all') {
      _filteredJobs = _appliedJobs;
    } else {
      _filteredJobs = _appliedJobs.where((job) =>
      job.application.Status.toLowerCase() == status.toLowerCase()
      ).toList();
    }
    notifyListeners();
  }

  Future<void> deleteApplication({
    required BuildContext context,
    required String applicationId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _service.deleteApplication(
        context: context,
        applicationId: applicationId,
      );

      if (success) {
        _appliedJobs.removeWhere((job) => job.application.ID == applicationId);

        filterByStatus(_statusFilter);
      } else {
        _errorMessage = "Không thể xóa đơn ứng tuyển";
      }
    } catch (e) {
      _errorMessage = "Lỗi khi xóa đơn ứng tuyển: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}