import 'package:ui/Models/Jobs.dart';

import 'Candidates.dart';

class cApplications_recruiter {
  final String ID;
  final String JobID;
  final String Status;
  final DateTime AppliedAt;
  final String? DeletedAt;
  final String ResumeUrl;
  final cCandidates_cApplication_recruiter Candidate;

  cApplications_recruiter({
    required this.ID,
    required this.JobID,
    required this.Status,
    required this.AppliedAt,
    this.DeletedAt,
    required this.ResumeUrl,
    required this.Candidate,
  });

  factory cApplications_recruiter.fromJson(Map<String, dynamic> json) {
    return cApplications_recruiter(
      ID: json['ID'],
      JobID: json['JobID'],
      Status: json['Status'],
      AppliedAt: DateTime.parse(json['AppliedAt']),
      DeletedAt: json['DeletedAt'],
      ResumeUrl: json['ResumeUrl'],
      Candidate: cCandidates_cApplication_recruiter.fromJson(json['Candidate']),
    );
  }

  cApplications_recruiter copyWith({String? status}) {
    return cApplications_recruiter(
      ID: this.ID,
      Status: status ?? this.Status,
      JobID: this.JobID,
      AppliedAt: this.AppliedAt,
      DeletedAt: this.DeletedAt,
      ResumeUrl: this.ResumeUrl,
      Candidate: this.Candidate,
    );
  }
}
class cApplications_candidate {
  final String ID;
  final String ResumeUrl;
  final String Status;
  final DateTime AppliedAt;
  final String? DeletedAt;
  final cJobs_recruiter? Job;

  cApplications_candidate({
    required this.ID,
    required this.ResumeUrl,
    required this.Status,
    required this.AppliedAt,
    required this.DeletedAt,
    required this.Job,
  });

  factory cApplications_candidate.fromJson(Map<String, dynamic> json) {
    return cApplications_candidate(
      ID: json['ID'],
      ResumeUrl: json['ResumeUrl'],
      Status: json['Status'],
      AppliedAt: DateTime.parse(json['AppliedAt']),
      DeletedAt: json['DeletedAt'],
      Job: json['Job'] != null
          ? cJobs_recruiter.fromJson(json['Job'])
          : null,
    );
  }
}
