import 'Candidates.dart';
import 'Enum.dart';
import 'Recruiters.dart';
import 'UserNotifications.dart';

class cUsers {
  String? ID;
  String? Email;
  String? Password;
  String? FullName;
  String? AvatarUrl;
  String? PhoneNumber;
  eUserStatus? Status;
  DateTime? CreatedAt;
  DateTime? UpdatedAt;
  eRole? Role;
  DateTime? DeletedAt;
  bool? IsEmailVerified;
  cCandidates? Candidates;
  cRecruiters? Recruiters;
  List<cUserNotifications>? UserNotifications;
}