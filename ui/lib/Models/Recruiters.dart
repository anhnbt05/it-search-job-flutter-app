import 'package:json_annotation/json_annotation.dart';

import 'CompanyLocations.dart';
import 'Jobs.dart';

part 'Recruiters.g.dart';

@JsonSerializable()
class Recruiters {
  final String id;
  final String position;
  final DateTime? deletedAt;
  final String userId;
  final List<Jobs> jobs;
  final String companyLocationId;
  final CompanyLocations companyLocation;

  Recruiters({
    required this.id,
    required this.position,
    this.deletedAt,
    required this.userId,
    required this.jobs,
    required this.companyLocationId,
    required this.companyLocation,
  });

  factory Recruiters.fromJson(Map<String, dynamic> json) => _$RecruitersFromJson(json);
  Map<String, dynamic> toJson() => _$RecruitersToJson(this);
}