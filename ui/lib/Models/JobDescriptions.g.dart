// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobDescriptions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobDescriptions _$JobDescriptionsFromJson(Map<String, dynamic> json) =>
    JobDescriptions(
      id: json['id'] as String,
      description: json['description'] as String,
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
      jobID: json['jobID'] as String,
      job: Jobs.fromJson(json['job'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JobDescriptionsToJson(JobDescriptions instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'jobID': instance.jobID,
      'job': instance.job,
    };
