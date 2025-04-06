// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'JobFavorites.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobFavorites _$JobFavoritesFromJson(Map<String, dynamic> json) => JobFavorites(
  id: json['id'] as String,
  savedAt: DateTime.parse(json['savedAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  candidateId: json['candidateId'] as String,
  jobId: json['jobId'] as String,
  candidate: Candidates.fromJson(json['candidate'] as Map<String, dynamic>),
  job: Jobs.fromJson(json['job'] as Map<String, dynamic>),
);

Map<String, dynamic> _$JobFavoritesToJson(JobFavorites instance) =>
    <String, dynamic>{
      'id': instance.id,
      'savedAt': instance.savedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'candidateId': instance.candidateId,
      'jobId': instance.jobId,
      'candidate': instance.candidate,
      'job': instance.job,
    };
