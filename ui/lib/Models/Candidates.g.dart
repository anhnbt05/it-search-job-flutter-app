// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Candidates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Candidates _$CandidatesFromJson(Map<String, dynamic> json) => Candidates(
  id: json['id'] as String,
  resumeUrl: json['resumeUrl'] as String?,
  certifications:
      (json['certifications'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  bio: json['bio'] as String?,
  level: $enumDecode(_$LevelEnumMap, json['level']),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  userId: json['userId'] as String,
  user: Users.fromJson(json['user'] as Map<String, dynamic>),
  applications:
      (json['applications'] as List<dynamic>)
          .map((e) => Applications.fromJson(e as Map<String, dynamic>))
          .toList(),
  jobFavorites:
      (json['jobFavorites'] as List<dynamic>)
          .map((e) => JobFavorites.fromJson(e as Map<String, dynamic>))
          .toList(),
  workExperiences:
      (json['workExperiences'] as List<dynamic>)
          .map((e) => WorkExperiences.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$CandidatesToJson(Candidates instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeUrl': instance.resumeUrl,
      'certifications': instance.certifications,
      'bio': instance.bio,
      'level': _$LevelEnumMap[instance.level]!,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'userId': instance.userId,
      'user': instance.user,
      'applications': instance.applications,
      'jobFavorites': instance.jobFavorites,
      'workExperiences': instance.workExperiences,
    };

const _$LevelEnumMap = {
  Level.intern: 'intern',
  Level.fresher: 'fresher',
  Level.mid: 'mid',
  Level.junior: 'junior',
  Level.senior: 'senior',
};
