import 'package:json_annotation/json_annotation.dart';

import 'Notifications.dart';
import 'Users.dart';

part 'UserNotifications.g.dart';

@JsonSerializable()
class UserNotifications {
  final String id;
  final List<String> content;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String userId;
  final String notificationId;
  final Users user;
  final Notifications notification;

  UserNotifications({
    required this.id,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.deletedAt,
    required this.userId,
    required this.notificationId,
    required this.user,
    required this.notification,
  });

  factory UserNotifications.fromJson(Map<String, dynamic> json) => _$UserNotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$UserNotificationsToJson(this);
}
