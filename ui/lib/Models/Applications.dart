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
