import 'Notifications.dart';
import 'UserNotifications.dart';
import 'Users.dart';

class UserNotification {
  final String ID;
  final bool IsRead;
  final List<String> Content;
  final Map<String, dynamic> Metadata;
  final DateTime CreatedAt;
  final cNotification Notification;

  UserNotification({
    required this.ID,
    required this.IsRead,
    required this.Content,
    required this.Metadata,
    required this.CreatedAt,
    required this.Notification,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      ID: json['ID'],
      IsRead: json['IsRead'],
      Content: List<String>.from(json['Content']),
      Metadata: Map<String, dynamic>.from(json['Metadata'] ?? {}),
      CreatedAt: DateTime.parse(json['CreatedAt']),
      Notification: cNotification.fromJson(json['Notification']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'IsRead': IsRead,
      'Content': Content,
      'Metadata': Metadata,
      'CreatedAt': CreatedAt.toIso8601String(),
      'Notification': Notification.toJson(),
    };
  }
}

class cNotification {
  final String Title;
  final String Type;

  cNotification({
    required this.Title,
    required this.Type,
  });

  factory cNotification.fromJson(Map<String, dynamic> json) {
    return cNotification(
      Title: json['Title'],
      Type: json['Type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Title': Title,
      'Type': Type,
    };
  }
}

