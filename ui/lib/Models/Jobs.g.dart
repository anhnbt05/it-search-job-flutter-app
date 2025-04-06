// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Jobs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Jobs _$JobsFromJson(Map<String, dynamic> json) => Jobs(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  address: json['address'] as String,
  salary: json['salary'] as String,
  vacancies: (json['vacancies'] as num).toInt(),
  type: $enumDecode(_$JobTypeEnumMap, json['type']),
  workingTimes: json['workingTimes'] as String,
  status: $enumDecode(_$JobStatusEnumMap, json['status']),
  postedAt: DateTime.parse(json['postedAt'] as String),
  expiredAt: DateTime.parse(json['expiredAt'] as String),
  level: $enumDecode(_$LevelEnumMap, json['level']),
  deletedAt:
      json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
  recruiterId: json['recruiterId'] as String,
  applications:
      (json['applications'] as List<dynamic>)
          .map((e) => Applications.fromJson(e as Map<String, dynamic>))
          .toList(),
  jobDescriptions:
      (json['jobDescriptions'] as List<dynamic>)
          .map((e) => JobDescriptions.fromJson(e as Map<String, dynamic>))
          .toList(),
  jobFavorites:
      (json['jobFavorites'] as List<dynamic>)
          .map((e) => JobFavorites.fromJson(e as Map<String, dynamic>))
          .toList(),
  jobRequirements:
      (json['jobRequirements'] as List<dynamic>)
          .map((e) => JobRequirements.fromJson(e as Map<String, dynamic>))
          .toList(),
  jobBenefits:
      (json['jobBenefits'] as List<dynamic>)
          .map((e) => JobBenefits.fromJson(e as Map<String, dynamic>))
          .toList(),
  recruiter: Recruiters.fromJson(json['recruiter'] as Map<String, dynamic>),
  jobCategories:
      (json['jobCategories'] as List<dynamic>)
          .map((e) => JobCategories.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$JobsToJson(Jobs instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'address': instance.address,
  'salary': instance.salary,
  'vacancies': instance.vacancies,
  'type': _$JobTypeEnumMap[instance.type]!,
  'workingTimes': instance.workingTimes,
  'status': _$JobStatusEnumMap[instance.status]!,
  'postedAt': instance.postedAt.toIso8601String(),
  'expiredAt': instance.expiredAt.toIso8601String(),
  'level': _$LevelEnumMap[instance.level]!,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'recruiterId': instance.recruiterId,
  'applications': instance.applications,
  'jobDescriptions': instance.jobDescriptions,
  'jobFavorites': instance.jobFavorites,
  'jobRequirements': instance.jobRequirements,
  'jobBenefits': instance.jobBenefits,
  'recruiter': instance.recruiter,
  'jobCategories': instance.jobCategories,
};

const _$JobTypeEnumMap = {
  JobType.part_time: 'part_time',
  JobType.full_time: 'full_time',
  JobType.remote: 'remote',
  JobType.free_lance: 'free_lance',
};

const _$JobStatusEnumMap = {
  JobStatus.open: 'open',
  JobStatus.closed: 'closed',
  JobStatus.pending: 'pending',
  JobStatus.rejected: 'rejected',
};

const _$LevelEnumMap = {
  Level.intern: 'intern',
  Level.fresher: 'fresher',
  Level.mid: 'mid',
  Level.junior: 'junior',
  Level.senior: 'senior',
};
