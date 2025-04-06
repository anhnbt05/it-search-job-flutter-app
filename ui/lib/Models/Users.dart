import 'package:json_annotation/json_annotation.dart';

import 'Candidates.dart';
import 'Enum.dart';
import 'Recruiters.dart';
import 'UserNotifications.dart';

part 'Users.g.dart';

@JsonSerializable()
class Users {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String? avatarUrl;
  final String phoneNumber;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Role role;
  final DateTime? deletedAt;
  final bool isEmailVerified;
  final Candidates? candidates;
  final Recruiters? recruiters;
  final List<UserNotifications> userNotifications;

  Users({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    this.avatarUrl,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.role,
    this.deletedAt,
    required this.isEmailVerified,
    this.candidates,
    this.recruiters,
    required this.userNotifications,
  });

  factory Users.fromJson(Map<String, dynamic> json) => _$UsersFromJson(json);
  Map<String, dynamic> toJson() => _$UsersToJson(this);
}