import 'package:json_annotation/json_annotation.dart';

import 'Applications.dart';
import 'Enum.dart';
import 'JobFavorites.dart';
import 'Users.dart';
import 'WorkExperiences.dart';

part 'Candidates.g.dart';

@JsonSerializable()
class Candidates {
  final String id;
  final String? resumeUrl;
  final List<String> certifications;
  final String? bio;
  final Level level;
  final DateTime? deletedAt;
  final String userId;
  final Users user;
  final List<Applications> applications;
  final List<JobFavorites> jobFavorites;
  final List<WorkExperiences> workExperiences;

  Candidates({
    required this.id,
    this.resumeUrl,
    required this.certifications,
    this.bio,
    required this.level,
    this.deletedAt,
    required this.userId,
    required this.user,
    required this.applications,
    required this.jobFavorites,
    required this.workExperiences,
  });

  factory Candidates.fromJson(Map<String, dynamic> json) => _$CandidatesFromJson(json);
  Map<String, dynamic> toJson() => _$CandidatesToJson(this);
}
