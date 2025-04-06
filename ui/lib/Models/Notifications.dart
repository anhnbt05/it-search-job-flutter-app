import 'package:json_annotation/json_annotation.dart';
import 'package:ui/Models/UserNotifications.dart';

import 'Enum.dart';

part 'Notifications.g.dart';

@JsonSerializable()
class Notifications {
  final String id;
  final String title;
  final NotificationType type;
  final DateTime? deletedAt;
  final List<UserNotifications> userNotifications;

  Notifications({
    required this.id,
    required this.title,
    required this.type,
    this.deletedAt,
    required this.userNotifications,
  });

  factory Notifications.fromJson(Map<String, dynamic> json) => _$NotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsToJson(this);
}
