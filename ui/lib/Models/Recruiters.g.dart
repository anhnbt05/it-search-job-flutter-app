// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Recruiters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recruiters _$RecruitersFromJson(Map<String, dynamic> json) => Recruiters(
  id: json['id'] as String,
  position: json['position'] as String,
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  userId: json['userId'] as String,
  jobs:
      (json['jobs'] as List<dynamic>)
          .map((e) => Jobs.fromJson(e as Map<String, dynamic>))
          .toList(),
  companyLocationId: json['companyLocationId'] as String,
  companyLocation: CompanyLocations.fromJson(
    json['companyLocation'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$RecruitersToJson(Recruiters instance) =>
    <String, dynamic>{
      'id': instance.id,
      'position': instance.position,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'userId': instance.userId,
      'jobs': instance.jobs,
      'companyLocationId': instance.companyLocationId,
      'companyLocation': instance.companyLocation,
    };
