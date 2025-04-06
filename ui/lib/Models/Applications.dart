import 'package:json_annotation/json_annotation.dart';

import 'Candidates.dart';
import 'Enum.dart';
import 'Jobs.dart';

part 'Applications.g.dart';

@JsonSerializable()
class Applications {
  final String id;
  final String resumeUrl;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? deletedAt;
  final String candidateId;
  final String jobId;
  final Candidates candidate;
  final Jobs job;

  Applications({
    required this.id,
    required this.resumeUrl,
    required this.status,
    required this.appliedAt,
    this.deletedAt,
    required this.candidateId,
    required this.jobId,
    required this.candidate,
    required this.job,
  });

  factory Applications.fromJson(Map<String, dynamic> json) => _$ApplicationsFromJson(json);
  Map<String, dynamic> toJson() => _$ApplicationsToJson(this);
}
