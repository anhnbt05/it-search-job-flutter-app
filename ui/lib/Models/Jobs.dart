import 'package:json_annotation/json_annotation.dart';

import 'Applications.dart';
import 'Enum.dart';
import 'JobBenefits.dart';
import 'JobCategories.dart';
import 'JobDescriptions.dart';
import 'JobFavorites.dart';
import 'JobRequirements.dart';
import 'Recruiters.dart';

part 'Jobs.g.dart';

@JsonSerializable()
class Jobs {
  final String id;
  final String title;
  final String? description;
  final String address;
  final String salary;
  final int vacancies;
  final JobType type;
  final String workingTimes;
  final JobStatus status;
  final DateTime postedAt;
  final DateTime expiredAt;
  final Level level;
  final DateTime? deletedAt;
  final String recruiterId;
  final List<Applications> applications;
  final List<JobDescriptions> jobDescriptions;
  final List<JobFavorites> jobFavorites;
  final List<JobRequirements> jobRequirements;
  final List<JobBenefits> jobBenefits;
  final Recruiters recruiter;
  final List<JobCategories> jobCategories;

  Jobs({
    required this.id,
    required this.title,
    this.description,
    required this.address,
    required this.salary,
    required this.vacancies,
    required this.type,
    required this.workingTimes,
    required this.status,
    required this.postedAt,
    required this.expiredAt,
    required this.level,
    this.deletedAt,
    required this.recruiterId,
    required this.applications,
    required this.jobDescriptions,
    required this.jobFavorites,
    required this.jobRequirements,
    required this.jobBenefits,
    required this.recruiter,
    required this.jobCategories,
  });

  factory Jobs.fromJson(Map<String, dynamic> json) => _$JobsFromJson(json);
  Map<String, dynamic> toJson() => _$JobsToJson(this);
}
