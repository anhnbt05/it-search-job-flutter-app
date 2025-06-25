import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Enum.dart';
import 'package:ui/Models/Recruiters.dart';
import 'package:ui/ViewModels/admin/UserManagementViewModel.dart';

import '../../Helpers/toastification.dart';
import '../../Models/Users.dart';
import '../../Services/user_service.dart';

class RecruiterInforViewModel extends ChangeNotifier {
  late cRecruiters? _recruiter;
  cRecruiters? get recruiter => _recruiter;
  late Future<cRecruiters?> _recruiterFuture;
  Future<cRecruiters?> get recruiterFuture => _recruiterFuture;

  RecruiterInforViewModel(BuildContext context, String userId) {
    _recruiterFuture = UserService().getRecruiterInfo_admin(Id: userId, context: context).then((value) {
      _recruiter = value;
      print(_recruiter!.Email);
      return value;
    });
  }

  Future<bool> banUser(BuildContext context) async {
    var parent = Provider.of<UserManagementViewModel>(context, listen: false);
    bool success = await UserService().lockUser('${_recruiter!.ID}?role=recruiter', context);
    if (success == true) {
      showSuccessToastification(title: "Hoàn tất", message: "Xóa thành công tài khoản của ${_recruiter!.FullName}");
      final index = parent.userRecruiter!.indexWhere((u) => u!.ID == _recruiter!.ID);
      if (index != -1) {
        parent.userRecruiter![index] =
            parent.userRecruiter![index]!.copyWith(Status: eUserStatus.inactive);
        parent.notifyListeners();
      }
    }
    return success;
  }

  Future<bool> unbanUser(BuildContext context) async {
    var parent = Provider.of<UserManagementViewModel>(context, listen: false);
    bool success = await UserService().unlockUser('${_recruiter!.ID}?role=recruiter', context);
    if (success == true) {
      final index = parent.userRecruiter!.indexWhere((u) => u!.ID == _recruiter!.ID);
      if (index != -1) {
        parent.userRecruiter![index] =
            parent.userRecruiter![index]!.copyWith(Status: eUserStatus.active);
        parent.notifyListeners();
      }
    }
    return success;
  }
}