// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserNotifications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserNotifications _$UserNotificationsFromJson(Map<String, dynamic> json) =>
    UserNotifications(
      id: json['id'] as String,
      content:
          (json['content'] as List<dynamic>).map((e) => e as String).toList(),
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
      userId: json['userId'] as String,
      notificationId: json['notificationId'] as String,
      user: Users.fromJson(json['user'] as Map<String, dynamic>),
      notification: Notifications.fromJson(
        json['notification'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$UserNotificationsToJson(UserNotifications instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'userId': instance.userId,
      'notificationId': instance.notificationId,
      'user': instance.user,
      'notification': instance.notification,
    };
