import 'Jobs.dart';
import 'package:json_annotation/json_annotation.dart';

part 'JobDescriptions.g.dart';

@JsonSerializable()
class JobDescriptions {
  String id;
  String description;
  DateTime? deletedAt;
  String jobID;
  Jobs job;

  JobDescriptions({
    required this.id,
    required this.description,
    this.deletedAt,
    required this.jobID,
    required this.job,
  });

  factory JobDescriptions.fromJson(Map<String, dynamic> json) => _$JobDescriptionsFromJson(json);
  Map<String, dynamic> toJson() => _$JobDescriptionsToJson(this);
}