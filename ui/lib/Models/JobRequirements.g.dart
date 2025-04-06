// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobRequirements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobRequirements _$JobRequirementsFromJson(Map<String, dynamic> json) =>
    JobRequirements(
      id: json['id'] as String,
      requirement: json['requirement'] as String,
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
      jobId: json['jobId'] as String,
      job: Jobs.fromJson(json['job'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobRequirementsToJson(JobRequirements instance) =>
    <String, dynamic>{
      'id': instance.id,
      'requirement': instance.requirement,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'jobId': instance.jobId,
      'job': instance.job,
    };
