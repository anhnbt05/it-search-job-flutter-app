import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Services/job_service.dart';

import '../../Models/Jobs.dart';
import 'RecruimentApprovalViewModel.dart';

class JobDetailViewModel extends ChangeNotifier {
  cJobs? _job;
  cJobs? get job => _job;
  late Future<cJobs?> _jobFuture;
  Future<cJobs?> get jobFuture => _jobFuture;

  JobDetailViewModel({required index, required context}) {
    var viewModel = Provider.of<RecruiterApprovalViewModel>(
        context, listen: false);
    _jobFuture = JobService().getJobByID(Id: viewModel.jobs![index]!.ID, context: context).then((value) {
      _job = value;
      notifyListeners();
      return value;
    });
  }
}