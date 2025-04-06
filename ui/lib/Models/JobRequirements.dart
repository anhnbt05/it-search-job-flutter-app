import 'Jobs.dart';
import 'package:json_annotation/json_annotation.dart';

part 'JobRequirements.g.dart';

@JsonSerializable()
class JobRequirements {
  String id;
  String requirement;
  DateTime? deletedAt;
  String jobId;
  Jobs job;

  JobRequirements({
    required this.id,
    required this.requirement,
    this.deletedAt,
    required this.jobId,
    required this.job,
  });

  factory JobRequirements.fromJson(Map<String, dynamic> json) => _$JobRequirementsFromJson(json);
  Map<String, dynamic> toJson() => _$JobRequirementsToJson(this);
}