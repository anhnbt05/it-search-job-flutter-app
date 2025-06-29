import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/CompanyLocations.dart';
import 'package:ui/ViewModels/AuthViewModel.dart';
import '../../Helpers/toastification.dart';
import '../../Models/Recruiters.dart';
import '../../Services/auth_companies_service.dart';
import '../../Services/auth_signout_service.dart';
import '../../Services/user_service.dart';

class RecruiterProfileViewModel extends ChangeNotifier {
  late String userId;
  late final Future<cRecruiters?>? _recruiterFuture;
  cRecruiters? _recruiterInfo;
  Future<cRecruiters?>? get recruiterFuture => _recruiterFuture;
  cRecruiters? get recruiterInfo => _recruiterInfo;

  set recruiterInfo(cRecruiters? value) {
    _recruiterInfo = value;
  }

  PageController pageController = PageController();
  List<cCompanyLocations?> _branches = [];

  set branches(List<cCompanyLocations?> value) {
    _branches = value;
  }

  List<cCompanyLocations?> get branches => _branches;
  RecruiterProfileViewModel(this.userId, BuildContext context) {
    _recruiterFuture =
        UserService().getRecruiterInfo(Id: userId, context: context).then((
            value) {
          _recruiterInfo = value;
          notifyListeners();
          AuthCompaniesService().fetchBranches(
              (recruiterInfo == null) ? "" : recruiterInfo!.Company.ID).then((
              value) {
            _branches = value.data;
            notifyListeners();
            return value;
          });
          return value;
        });
  }

  Future<void> signOut(BuildContext context) async {
    await AuthSignOutService().signOut(context);
    final authService = Provider.of<AuthViewModel>(context, listen: false);
    authService.logout(context);
    authService.notifyListeners();
  }
}