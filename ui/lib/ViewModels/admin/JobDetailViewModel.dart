import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/Services/job_service.dart';

import '../../Models/Jobs.dart';
import 'RecruimentApprovalViewModel.dart';

class JobDetailViewModel extends ChangeNotifier {
  TextEditingController _reasonController = TextEditingController();
  cJobs? _job;
  cJobs? get job => _job;
  late Future<cJobs?> _jobFuture;
  Future<cJobs?> get jobFuture => _jobFuture;
  TextEditingController get reasonController => _reasonController;

  JobDetailViewModel({required index, required context}) {
    var viewModel = Provider.of<RecruiterApprovalViewModel>(
        context, listen: false);
    _jobFuture = JobService().getJobByID(Id: viewModel.jobs![index]!.ID, context: context).then((value) {
      _job = value;
      notifyListeners();
      return value;
    });
  }

  Future<ResponseModel> approveJob(BuildContext context) async {
    var vm = Provider.of<RecruiterApprovalViewModel>(context, listen: false);
    ResponseModel response = await JobService().approveJob(Id: _job!.ID, context: context);
    if (response.success) {
      vm.jobs!.removeWhere((e) => e!.ID == _job!.ID);
      vm.notifyListeners();
    }
    return response;
  }

  Future<ResponseModel> rejectJob(BuildContext context) async {
    var vm = Provider.of<RecruiterApprovalViewModel>(context, listen: false);
    ResponseModel response = await JobService().rejectJob(Id: _job!.ID, reason: reasonController.text, context: context);
    if (response.success) {
      vm.jobs!.removeWhere((e) => e!.ID == _job!.ID);
      vm.notifyListeners();
    }
    return response;
  }
}