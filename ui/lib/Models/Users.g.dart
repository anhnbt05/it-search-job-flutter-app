// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Users.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Users _$UsersFromJson(Map<String, dynamic> json) => Users(
  id: json['id'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  fullName: json['fullName'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  phoneNumber: json['phoneNumber'] as String,
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  role: $enumDecode(_$RoleEnumMap, json['role']),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  isEmailVerified: json['isEmailVerified'] as bool,
  candidates:
      json['candidates'] == null
          ? null
          : Candidates.fromJson(json['candidates'] as Map<String, dynamic>),
  recruiters:
      json['recruiters'] == null
          ? null
          : Recruiters.fromJson(json['recruiters'] as Map<String, dynamic>),
  userNotifications:
      (json['userNotifications'] as List<dynamic>)
          .map((e) => UserNotifications.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UsersToJson(Users instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'password': instance.password,
  'fullName': instance.fullName,
  'avatarUrl': instance.avatarUrl,
  'phoneNumber': instance.phoneNumber,
  'status': _$UserStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'role': _$RoleEnumMap[instance.role]!,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'isEmailVerified': instance.isEmailVerified,
  'candidates': instance.candidates,
  'recruiters': instance.recruiters,
  'userNotifications': instance.userNotifications,
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.inactive: 'inactive',
};

const _$RoleEnumMap = {
  Role.admin: 'admin',
  Role.recruiter: 'recruiter',
  Role.candidate: 'candidate',
};
