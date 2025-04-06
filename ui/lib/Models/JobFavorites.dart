import 'package:json_annotation/json_annotation.dart';

import 'Candidates.dart';
import 'Jobs.dart';

part 'JobFavorites.g.dart';

@JsonSerializable()
class JobFavorites {
  final String id;
  final DateTime savedAt;
  final DateTime? deletedAt;
  final String candidateId;
  final String jobId;
  final Candidates candidate;
  final Jobs job;

  JobFavorites({
    required this.id,
    required this.savedAt,
    this.deletedAt,
    required this.candidateId,
    required this.jobId,
    required this.candidate,
    required this.job,
  });

  factory JobFavorites.fromJson(Map<String, dynamic> json) => _$JobFavoritesFromJson(json);
  Map<String, dynamic> toJson() => _$JobFavoritesToJson(this);
}
