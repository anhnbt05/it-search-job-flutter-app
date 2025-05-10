import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/CompanyLocations.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/ViewModels/login/SignInViewModel.dart';

import '../../Constants/api_constants.dart';
import '../../Models/Recruiters.dart';
import '../../Services/auth_companies_service.dart';
import '../../Services/user_service.dart';

class RecruiterProfileViewModel extends ChangeNotifier {
  late final Future<cRecruiters?>? _recruiterFuture;
  cRecruiters? _recruiterInfo;
  Future<cRecruiters?>? get recruiterFuture => _recruiterFuture;
  cRecruiters? get recruiterInfo => _recruiterInfo;
  PageController pageController = PageController();
  List<cCompanyLocations?> _branches = [];

  List<cCompanyLocations?> get branches => _branches;
  late final Future<ResponseModel> _branchesFuture;

  RecruiterProfileViewModel(String userId, BuildContext context) {
    var authViewModel = Provider.of<SignInViewModel>(context, listen: false);
    _recruiterFuture = UserService().getRecruiterInfo(Id: userId, accessToken: APIConstants.accessToken, authViewModel: authViewModel).then((value) {
      _recruiterInfo = value;
      _branchesFuture = AuthCompaniesService().fetchBranches((recruiterInfo == null) ? "" : recruiterInfo!.Company.ID).then((value) {
        _branches = value.data;
        return value;
      });
      return value;
    });
  }
}