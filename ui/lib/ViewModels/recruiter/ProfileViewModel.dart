import 'package:flutter/cupertino.dart';
import 'package:ui/Models/CompanyLocations.dart';
import '../../Models/Recruiters.dart';
import '../../Services/auth_companies_service.dart';
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
    _recruiterFuture = UserService().getRecruiterInfo(Id: userId, context: context).then((value) {
      _recruiterInfo = value;
        AuthCompaniesService().fetchBranches((recruiterInfo == null) ? "" : recruiterInfo!.Company.ID).then((value) {
        _branches = value.data;
        return value;
      });
      return value;
    });
  }
}