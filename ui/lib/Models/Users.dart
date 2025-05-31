import 'Enum.dart';
import 'Recruiters.dart';
import 'UserNotifications.dart';

class cUsers {
  String? ID;
  String? Email;
  String? FullName;
  String? AvatarUrl;
  String? PhoneNumber;
  eUserStatus? Status;
  DateTime? CreatedAt;
  DateTime? UpdatedAt;
  eRole? Role;
  DateTime? DeletedAt;
  bool? IsEmailVerified;

  cUsers({
    this.ID,
    this.Email,
    this.FullName,
    this.AvatarUrl,
    this.PhoneNumber,
    this.Status,
    this.CreatedAt,
    this.UpdatedAt,
    this.Role,
    this.DeletedAt,
    this.IsEmailVerified,
  });

  factory cUsers.fromJson(Map<String, dynamic> json) {
    return cUsers(
      ID: json['ID'],
      Email: json['Email'],
      FullName: json['FullName'],
      AvatarUrl: json['AvatarUrl'],
      PhoneNumber: json['PhoneNumber'],
      Status: eUserStatus.values.firstWhere(
            (x) => x.toString().split('.').last == json['Status'],
        orElse: () => eUserStatus.inactive, // hoặc giá trị mặc định
      ),
      CreatedAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      UpdatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      Role: eRole.values.firstWhere(
            (x) => x.toString().split('.').last == json['Role'],
        orElse: () => eRole.candidate, // hoặc giá trị mặc định
      ),
      DeletedAt: json['DeletedAt'] != null ? DateTime.tryParse(json['DeletedAt']) : null,
      IsEmailVerified: json['IsEmailVerified'],
    );
  }

  Map<String, dynamic> toJson() => {
    'ID': ID,
    'Email': Email,
    'FullName': FullName,
    'AvatarUrl': AvatarUrl,
    'PhoneNumber': PhoneNumber,
    'Status': Status?.toString().split('.').last,
    'CreatedAt': CreatedAt?.toIso8601String(),
    'UpdatedAt': UpdatedAt?.toIso8601String(),
    'Role': Role?.toString().split('.').last,
    'DeletedAt': DeletedAt?.toIso8601String(),
    'IsEmailVerified': IsEmailVerified,
  };
}