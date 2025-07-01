import 'dart:core';

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

class cCompany_RecruiterInfo {
  final String ID;
  final String Name;
  final String? LogoUrl;
  final String CreatedAt;
  final String UpdatedAt;
  final String WebsiteUrl;
  final String Description;

  cCompany_RecruiterInfo({
    required this.ID,
    required this.Name,
    this.LogoUrl,
    required this.CreatedAt,
    required this.UpdatedAt,
    required this.WebsiteUrl,
    required this.Description,
  });

  factory cCompany_RecruiterInfo.fromJson(Map<String, dynamic> json) {
    return cCompany_RecruiterInfo(
      ID: json['ID'],
      Name: json['Name'],
      LogoUrl: json['LogoUrl'],
      CreatedAt: json['CreatedAt'],
      UpdatedAt: json['UpdatedAt'],
      WebsiteUrl: json['WebsiteUrl'],
      Description: json['Description'],
    );
  }
}

class cCompany_Job {
  final String ID;
  final String Name;
  final String? LogoUrl;
  final String WebsiteUrl;
  final String Description;

  cCompany_Job({
    required this.ID,
    required this.Name,
    required this.LogoUrl,
    required this.WebsiteUrl,
    required this.Description,
  });

  factory cCompany_Job.fromJson(Map<String, dynamic> json) {
    return cCompany_Job(
      ID: json['ID'],
      Name: json['Name'],
      LogoUrl: json['LogoUrl'],
      WebsiteUrl: json['WebsiteUrl'],
      Description: json['Description'],
    );
  }
}