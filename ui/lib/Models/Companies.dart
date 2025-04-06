import 'package:json_annotation/json_annotation.dart';

import 'CompanyLocations.dart';

part 'Companies.g.dart';

@JsonSerializable()
class Companies {
  final String id;
  final String name;
  final String? websiteUrl;
  final String? logoUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CompanyLocations> companyLocations; // Assuming CompanyLocation is another model

  Companies({
    required this.id,
    required this.name,
    this.websiteUrl,
    this.logoUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.companyLocations,
  });

  // Factory method for JSON deserialization
  factory Companies.fromJson(Map<String, dynamic> json) => _$CompaniesFromJson(json);

  // Method for JSON serialization
  Map<String, dynamic> toJson() => _$CompaniesToJson(this);
}