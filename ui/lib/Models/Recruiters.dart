import 'Companies.dart';

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