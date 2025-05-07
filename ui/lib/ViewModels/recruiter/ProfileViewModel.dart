import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/ViewModels/login/SignInViewModel.dart';

import '../../Constants/api_constants.dart';
import '../../Models/Recruiters.dart';
import '../../Services/user_service.dart';

class RecruiterProfileViewModel extends ChangeNotifier {
  late final Future<cRecruiters?>? _recruiterFuture;
  cRecruiters? _recruiterInfo;
  Future<cRecruiters?>? get recruiterFuture => _recruiterFuture;
  cRecruiters? get recruiterInfo => _recruiterInfo;

  RecruiterProfileViewModel(String userId, BuildContext context) {
    var authViewModel = Provider.of<SignInViewModel>(context, listen: false);
    _recruiterFuture = UserService().getRecruiterInfo(Id: userId, accessToken: APIConstants.accessToken, authViewModel: authViewModel).then((value) => _recruiterInfo = value);
  }
}