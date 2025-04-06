// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobBenefits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobBenefits _$JobBenefitsFromJson(Map<String, dynamic> json) => JobBenefits(
  id: json['id'] as String,
  benefit: json['benefit'] as String,
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  jobID: json['jobID'] as String,
  job: Jobs.fromJson(json['job'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JobBenefitsToJson(JobBenefits instance) =>
    <String, dynamic>{
      'id': instance.id,
      'benefit': instance.benefit,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'jobID': instance.jobID,
      'job': instance.job,
    };
