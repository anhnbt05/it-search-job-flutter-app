import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../Helpers/toastification.dart';
import '../../Models/Candidates.dart';
import '../../Models/Enum.dart';
import '../../Services/auth_signout_service.dart';
import '../../Services/user_service.dart';
import '../AuthViewModel.dart';
import 'UserManagementViewModel.dart';

class CandidateInforViewModel extends ChangeNotifier {
  final String candidateId;
  final UserService _userService = UserService();

  Candidate_admin? _candidate;
  bool _isLoading = false;
  String? _error;

  Candidate_admin? get candidate => _candidate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CandidateInforViewModel(this.candidateId);

  Future<void> fetchCandidateInfo({
    required BuildContext context,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print(candidateId);
      final result = await _userService.getCandidateInfo_admin(
        Id: candidateId,
        context: context,
      );

      if (result != null) {
        _candidate = result;
      } else {
        _error = "Không thể tải thông tin ứng viên.";
      }
    } catch (e) {
      _error = "Đã xảy ra lỗi: $e";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await AuthSignOutService().signOut(context);
      final authService = Provider.of<AuthViewModel>(context, listen: false);
      authService.logout(context);
      authService.notifyListeners();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  Future<bool> banUser(BuildContext context) async {
    var parent = Provider.of<UserManagementViewModel>(context, listen: false);
    bool success = await UserService().lockUser('${_candidate!.ID}?role=candidate', context);
    if (success == true) {
      showSuccessToastification(title: "Hoàn tất", message: "Xóa thành công tài khoản của ${_candidate!.FullName}");
      final index = parent.userCandidates!.indexWhere((u) => u!.ID == _candidate!.ID);
      if (index != -1) {
        parent.userCandidates![index] =
            parent.userCandidates![index]!.copyWith(Status: eUserStatus.inactive);
        parent.notifyListeners();
      }
    }
    return success;
  }

  Future<bool> unbanUser(BuildContext context) async {
    var parent = Provider.of<UserManagementViewModel>(context, listen: false);
    bool success = await UserService().unlockUser('${_candidate!.ID}?role=candidate', context);
    if (success == true) {
      final index = parent.userCandidates!.indexWhere((u) =>
      u!.ID == _candidate!.ID);
      if (index != -1) {
        parent.userCandidates![index] =
            parent.userCandidates![index]!.copyWith(Status: eUserStatus.active);
        parent.notifyListeners();
      }
    }
    return success;
  }
}