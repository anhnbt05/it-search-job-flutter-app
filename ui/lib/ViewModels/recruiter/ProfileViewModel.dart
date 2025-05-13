import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/CompanyLocations.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/ViewModels/login/SignInViewModel.dart';

import '../../Constants/api_constants.dart';
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

  List<cCompanyLocations?> get branches => _branches;
  late final Future<ResponseModel> _branchesFuture;

  RecruiterProfileViewModel(this.userId, BuildContext context) {
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