import 'Companies.dart';
import 'CompanyLocations.dart';

class cRecruiterPost {
  final String ID;
  final String Position;
  final String? DeletedAt;
  final String FullName;
  final cCompanies Company;

  cRecruiterPost({
    required this.ID,
    required this.Position,
    this.DeletedAt,
    required this.FullName,
    required this.Company,
  });

  factory cRecruiterPost.fromJson(Map<String, dynamic> json) {
    return cRecruiterPost(
      ID: json['ID'],
      Position: json['Position'],
      DeletedAt: json['DeletedAt'],
      FullName: json['FullName'],
      Company: cCompanies.fromJson(json['Company']),
    );
  }
}

class cRecruiters {
  final String ID;
  final String Position;
  final String FullName;
  final String Email;
  final String AvatarUrl;
  final String PhoneNumber;
  final bool IsEmailVerified;
  final cCompany_RecruiterInfo Company;
  final cCompanyLocation_RecruiterInfo CompanyLocations;

  cRecruiters({
    required this.ID,
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
      ID: json['ID'],
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
}

