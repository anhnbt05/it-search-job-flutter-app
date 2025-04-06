// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Applications.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Applications _$ApplicationsFromJson(Map<String, dynamic> json) => Applications(
  id: json['id'] as String,
  resumeUrl: json['resumeUrl'] as String,
  status: $enumDecode(_$ApplicationStatusEnumMap, json['status']),
  appliedAt: DateTime.parse(json['appliedAt'] as String),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  candidateId: json['candidateId'] as String,
  jobId: json['jobId'] as String,
  candidate: Candidates.fromJson(json['candidate'] as Map<String, dynamic>),
  job: Jobs.fromJson(json['job'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApplicationsToJson(Applications instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeUrl': instance.resumeUrl,
      'status': _$ApplicationStatusEnumMap[instance.status]!,
      'appliedAt': instance.appliedAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'candidateId': instance.candidateId,
      'jobId': instance.jobId,
      'candidate': instance.candidate,
      'job': instance.job,
    };

const _$ApplicationStatusEnumMap = {
  ApplicationStatus.pending: 'pending',
  ApplicationStatus.accepted: 'accepted',
  ApplicationStatus.rejected: 'rejected',
};
