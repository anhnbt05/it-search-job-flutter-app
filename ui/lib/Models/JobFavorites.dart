import 'Candidates.dart';
import 'Jobs.dart';

class cJobFavorites {
  String? ID;
  DateTime? SavedAt;
  DateTime? DeletedAt;
  cJobs_recruiter? Job;

  cJobFavorites({
    this.ID,
    this.SavedAt,
    this.DeletedAt,
    this.Job,
  });

  factory cJobFavorites.fromJson(Map<String, dynamic> json) {
    return cJobFavorites(
      ID: json['ID'],
      SavedAt: DateTime.tryParse(json['SavedAt']),
      DeletedAt: json['DeletedAt'] != null ? DateTime.tryParse(json['DeletedAt']) : null,
      Job: json['Job'] != null ? cJobs_recruiter.fromJson(json['Job']) : null,
    );
  }
}
