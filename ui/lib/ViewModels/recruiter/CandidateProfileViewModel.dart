import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/Candidates.dart';
import 'package:ui/Services/user_service.dart';

import '../../Constants/api_constants.dart';
import '../../Services/auth_signout_service.dart';
import '../AuthViewModel.dart';

class CandidateProfileViewModel extends ChangeNotifier {
  final String candidateId;
  final UserService _userService = UserService();

  cCandidates_cApplication_recruiter? _candidate;
  bool _isLoading = false;
  String? _error;

  cCandidates_cApplication_recruiter? get candidate => _candidate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CandidateProfileViewModel(this.candidateId);

  Future<void> fetchCandidateInfo({
    required BuildContext context,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _userService.getCandidateInfo(
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
}