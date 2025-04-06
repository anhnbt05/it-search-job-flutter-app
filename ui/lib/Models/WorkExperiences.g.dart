// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'WorkExperiences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkExperiences _$WorkExperiencesFromJson(Map<String, dynamic> json) =>
    WorkExperiences(
      id: json['id'] as String,
      companyName: json['companyName'] as String,
      companyLogoUrl: json['companyLogoUrl'] as String,
      position: json['position'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate:
          json['endDate'] == null
              ? null
              : DateTime.parse(json['endDate'] as String),
      descriptions:
          (json['descriptions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      location: json['location'] as String,
      jobType: $enumDecode(_$JobTypeEnumMap, json['jobType']),
      candidateId: json['candidateId'] as String,
      candidate: Candidates.fromJson(json['candidate'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkExperiencesToJson(WorkExperiences instance) =>
    <String, dynamic>{
      'id': instance.id,
      'companyName': instance.companyName,
      'companyLogoUrl': instance.companyLogoUrl,
      'position': instance.position,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'descriptions': instance.descriptions,
      'location': instance.location,
      'jobType': _$JobTypeEnumMap[instance.jobType]!,
      'candidateId': instance.candidateId,
      'candidate': instance.candidate,
    };

const _$JobTypeEnumMap = {
  JobType.part_time: 'part_time',
  JobType.full_time: 'full_time',
  JobType.remote: 'remote',
  JobType.free_lance: 'free_lance',
};
