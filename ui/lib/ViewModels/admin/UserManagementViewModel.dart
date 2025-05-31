import 'package:flutter/cupertino.dart';
import 'package:ui/Models/Enum.dart';

import '../../Models/Users.dart';
import '../../Services/user_service.dart';

class UserManagementViewModel extends ChangeNotifier {
  Future<List<cUsers?>>? _usersFuture;
  List<cUsers?>? _users;
  List<cUsers?>? _userCandidate;
  List<cUsers?>? _userRecruiter;

  Future<List<cUsers?>>? get usersFuture => _usersFuture;
  List<cUsers?>? get users => _users;

  List<cUsers?>? get userCandidates => _userCandidate;
  List<cUsers?>? get userRecruiter => _userRecruiter;

  UserManagementViewModel(BuildContext context) {
    _usersFuture = UserService().getAllUser(context).then((usersF) {
      _users = usersF;
      _userCandidate = users?.where((element) => element!.Role == eRole.candidate).toList();
      _userRecruiter = users?.where((element) => element!.Role == eRole.recruiter).toList();
      return usersF;
    });
  }
}