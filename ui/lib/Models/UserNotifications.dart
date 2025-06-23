import 'Notifications.dart';
import 'Users.dart';

class cUserNotifications {
  String? ID;
  List<String>? Content;
  bool? IsRead;
  DateTime? CreatedAt;
  DateTime? CeletedAt;
  cUsers? User;
  cNotifications? Notification;

}

class AdminNotification {
  final String id;
  final bool isRead;
  final List<String> content;
  final AdminMetadata metadata;
  final DateTime createdAt;

  AdminNotification({
    required this.id,
    required this.isRead,
    required this.content,
    required this.metadata,
    required this.createdAt,
  });

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: json['ID'],
      isRead: json['IsRead'],
      content: List<String>.from(json['Content']),
      metadata: AdminMetadata.fromJson(json['Metadata']),
      createdAt: DateTime.parse(json['CreatedAt']),
    );
  }
}

class AdminMetadata {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String recruiterId;

  AdminMetadata({
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.recruiterId,
  });

  factory AdminMetadata.fromJson(Map<String, dynamic> json) {
    return AdminMetadata(
      jobId: json['jobId'],
      jobTitle: json['jobTitle'],
      companyName: json['companyName'],
      recruiterId: json['recruiterId'],
    );
  }
}
