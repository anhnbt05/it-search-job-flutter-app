import 'package:flutter/cupertino.dart';
import 'package:ui/Models/Recruiters.dart';

import '../../Services/user_service.dart';

class RecruiterInforViewModel extends ChangeNotifier {
  late cRecruiters? _recruiter;
  cRecruiters? get recruiter => _recruiter;
  late Future<cRecruiters?> _recruiterFuture;
  Future<cRecruiters?> get recruiterFuture => _recruiterFuture;

  RecruiterInforViewModel(BuildContext context, String userId) {
    _recruiterFuture = UserService().getRecruiterInfo(Id: userId, context: context).then((value) {
      _recruiter = value;
      print(_recruiter!.Email);
      return value;
    });
  }
}