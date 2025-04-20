import 'CompanyLocations.dart';

class cCompanies {
  String? ID;
  String? Name;
  String? WebsiteUrl;
  String? LogoUrl;
  String? Description;
  DateTime? CreatedAt;
  DateTime? UpdatedAt;
  List<cCompanyLocations>? CompanyLocations;

  cCompanies({
    this.ID,
    this.Name,
    this.WebsiteUrl,
    this.LogoUrl,
    this.Description,
    this.CreatedAt,
    this.UpdatedAt,
    this.CompanyLocations,
  });

  factory cCompanies.fromJson(Map<String, dynamic> json) {
    return cCompanies(
      ID: json['ID']?.toString(),
      Name: json['Name'],
      WebsiteUrl: json['WebsiteUrl'],
      LogoUrl: json['LogoUrl'],
      Description: json['Description'],
      CreatedAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      UpdatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      CompanyLocations: json['CompanyLocations'] != null
          ? (json['CompanyLocations'] as List)
          .map((e) => cCompanyLocations.fromJson(e))
          .toList()
          : null,
    );
  }
}
