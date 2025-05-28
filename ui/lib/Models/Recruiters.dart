import 'Companies.dart';
import 'CompanyLocations.dart';

class cRecruiterPost {
  final String Position;
  final String? DeletedAt;
  final String FullName;
  final cCompanies Company;
  final String? AvatarUrl;

  cRecruiterPost({
    required this.Position,
    this.DeletedAt,
    required this.FullName,
    required this.Company,
    required this.AvatarUrl,
  });

  factory cRecruiterPost.fromJson(Map<String, dynamic> json) {
    return cRecruiterPost(
      AvatarUrl: json['AvatarUrl'],
      Position: json['Position'],
      DeletedAt: json['DeletedAt'],
      FullName: json['FullName'],
      Company: cCompanies.fromJson(json['Company']),
    );
  }
}

class cRecruiters {
  final String Position;
  final String FullName;
  final String Email;
  final String AvatarUrl;
  final String PhoneNumber;
  final bool IsEmailVerified;
  late cCompany_RecruiterInfo Company;
  final cCompanyLocation_RecruiterInfo CompanyLocations;

  cRecruiters({
    required this.Position,
    required this.FullName,
    required this.Email,
    required this.AvatarUrl,
    required this.PhoneNumber,
    required this.IsEmailVerified,
    required this.Company,
    required this.CompanyLocations,
  });

  factory cRecruiters.fromJson(Map<String, dynamic> json) {
    return cRecruiters(
      Position: json['Position'],
      FullName: json['FullName'],
      Email: json['Email'],
      AvatarUrl: json['AvatarUrl'],
      PhoneNumber: json['PhoneNumber'],
      IsEmailVerified: json['IsEmailVerified'],
      Company: cCompany_RecruiterInfo.fromJson(json['Company']),
      CompanyLocations: cCompanyLocation_RecruiterInfo.fromJson(json['CompanyLocations']),
    );
  }

  cRecruiters CopyRecruiterInfor({
    required String newFullName,
    required String newPhoneNumber,
    required String newPosition,
    required String newAvatarUrl,
  }) {
    return cRecruiters(
      Position: newPosition,
      FullName: newFullName,
      Email: Email,
      AvatarUrl: newAvatarUrl,
      PhoneNumber: newPhoneNumber,
      IsEmailVerified: IsEmailVerified,
      Company: Company,
      CompanyLocations: CompanyLocations,
    );
  }
}

class cRecruiter_Job {
  final String ID;
  final String Position;
  final String FullName;
  final cCompany_Job Company;

  cRecruiter_Job({
    required this.ID,
    required this.Position,
    required this.FullName,
    required this.Company,
  });

  factory cRecruiter_Job.fromJson(Map<String, dynamic> json) {
    return cRecruiter_Job(
      ID: json['ID'],
      Position: json['Position'],
      FullName: json['FullName'],
      Company: cCompany_Job.fromJson(json['Company']),
    );
  }
}

