import 'package:flutter/cupertino.dart';
import 'package:ui/Models/Enum.dart';

import '../../Helpers/helpers.dart';
import '../../Models/Users.dart';
import '../../Services/user_service.dart';

class UserManagementViewModel extends ChangeNotifier {
  Future<List<cUsers?>>? _usersFuture;
  List<cUsers?>? _users;
  List<cUsers?>? _userCandidate;
  List<cUsers?>? _userRecruiter;
  List<cUsers?>? _recruiterList;
  List<cUsers?>? _candidateList;
  String _statusFilter_recruiter = 'all';
  String _statusFilter_candidate = 'all';

  Future<List<cUsers?>>? get usersFuture => _usersFuture;
  List<cUsers?>? get users => _users;

  List<cUsers?>? get userCandidates => _userCandidate;
  List<cUsers?>? get userRecruiter => _userRecruiter;

  get statusFilter_recruiter => _statusFilter_recruiter;
  get statusFilter_candidate => _statusFilter_candidate;

  UserManagementViewModel(BuildContext context) {
    _usersFuture = UserService().getAllUser(context).then((usersF) {
      _users = usersF;
      _recruiterList = users?.where((element) => element!.Role == eRole.recruiter).toList();
      _candidateList = users?.where((element) => element!.Role == eRole.candidate).toList();
      _userRecruiter = _recruiterList;
      _userCandidate = _candidateList;
      return usersF;
    });
  }

  void filterRecruiterByName(String query) {
    final q = query.toLowerCase().trim();
    _userRecruiter = _recruiterList?.where((e) {
      final title = e?.FullName!.toLowerCase() ?? '';
      return removeVietnameseAccentsRegex(title).contains(removeVietnameseAccentsRegex(q));
    }).toList();
    notifyListeners();
  }

  void filterRecruiterByStatus(String? value) {
    _statusFilter_recruiter = value!;
    if (value == 'all') {
      _userRecruiter = _recruiterList;
    } else if (value == 'active') {
      _userRecruiter = _recruiterList?.where((element) => element!.Status == eUserStatus.active).toList();
    } else if (value == 'inactive') {
      _userRecruiter = _recruiterList?.where((element) => element!.Status == eUserStatus.inactive).toList();
    }
    notifyListeners();
  }

  void filterCandidateByName(String query) {
    final q = query.toLowerCase().trim();
    _userCandidate = _candidateList?.where((e) {
      final title = e?.FullName!.toLowerCase() ?? '';
      return removeVietnameseAccentsRegex(title).contains(removeVietnameseAccentsRegex(q));
    }).toList();
    notifyListeners();
  }

  void filterCandidateByStatus(String? value) {
    _statusFilter_candidate = value!;
    if (value == 'all') {
      _userCandidate = _candidateList;
    } else if (value == 'active') {
      _userCandidate = _candidateList?.where((element) => element!.Status == eUserStatus.active).toList();
    } else if (value == 'inactive') {
      _userCandidate = _candidateList?.where((element) => element!.Status == eUserStatus.inactive).toList();
    }
    print(_userCandidate?.length);
    notifyListeners();
  }
}