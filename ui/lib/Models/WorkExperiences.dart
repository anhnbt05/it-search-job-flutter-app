import 'package:json_annotation/json_annotation.dart';

import 'Candidates.dart';
import 'Enum.dart';

part 'WorkExperiences.g.dart';

@JsonSerializable()
class WorkExperiences {
  final String id;
  final String companyName;
  final String companyLogoUrl;
  final String position;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> descriptions;
  final String location;
  final JobType jobType;
  final String candidateId;
  final Candidates candidate;

  WorkExperiences({
    required this.id,
    required this.companyName,
    required this.companyLogoUrl,
    required this.position,
    required this.startDate,
    this.endDate,
    required this.descriptions,
    required this.location,
    required this.jobType,
    required this.candidateId,
    required this.candidate,
  });

  factory WorkExperiences.fromJson(Map<String, dynamic> json) => _$WorkExperiencesFromJson(json);
  Map<String, dynamic> toJson() => _$WorkExperiencesToJson(this);
}
