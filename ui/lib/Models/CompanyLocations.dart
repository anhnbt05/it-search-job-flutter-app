import 'package:json_annotation/json_annotation.dart';

import 'Companies.dart';
import 'Locations.dart';
import 'Recruiters.dart';

part 'CompanyLocations.g.dart';

@JsonSerializable()
class CompanyLocations {
  final String id;
  final String branchName;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String companyId;
  final String locationId;
  final Companies company;
  final Locations location;
  final List<Recruiters> recruiters;

  CompanyLocations({
    required this.id,
    required this.branchName,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.companyId,
    required this.locationId,
    required this.company,
    required this.location,
    required this.recruiters,
  });

  factory CompanyLocations.fromJson(Map<String, dynamic> json) => _$CompanyLocationsFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyLocationsToJson(this);
}