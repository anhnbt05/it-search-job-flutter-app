// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Notifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notifications _$NotificationsFromJson(Map<String, dynamic> json) =>
    Notifications(
      id: json['id'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
      userNotifications:
          (json['userNotifications'] as List<dynamic>)
              .map((e) => UserNotifications.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$NotificationsToJson(Notifications instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'userNotifications': instance.userNotifications,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.candidate_application_approved:
      'candidate_application_approved',
  NotificationType.candidate_application_rejected:
      'candidate_application_rejected',
  NotificationType.recruiter_job_approved: 'recruiter_job_approved',
  NotificationType.recruiter_job_rejected: 'recruiter_job_rejected',
  NotificationType.recruiter_new_application: 'recruiter_new_application',
  NotificationType.admin_new_job_post: 'admin_new_job_post',
};
