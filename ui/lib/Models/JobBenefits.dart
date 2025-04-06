import 'Jobs.dart';
import 'package:json_annotation/json_annotation.dart';

part 'JobBenefits.g.dart';

@JsonSerializable()
class JobBenefits {
  String id;
  String benefit;
  DateTime? deletedAt;
  String jobID;
  Jobs job;

  JobBenefits({
    required this.id,
    required this.benefit,
    this.deletedAt,
    required this.jobID,
    required this.job,
  });

  factory JobBenefits.fromJson(Map<String, dynamic> json) => _$JobBenefitsFromJson(json);
  Map<String, dynamic> toJson() => _$JobBenefitsToJson(this);
}