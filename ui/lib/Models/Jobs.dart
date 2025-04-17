import 'Recruiters.dart';

class cJobs_recruiter {
  final String ID;
  final String Title;
  final String Description;
  final String Address;
  final String Salary;
  final int Vacancies;
  final String Type;
  final String WorkingTimes;
  final String Status;
  final DateTime PostedAt;
  final DateTime ExpiredAt;
  final String Level;
  final String? DeletedAt;
  final cRecruiterPost Recruiter;

  cJobs_recruiter({
    required this.ID,
    required this.Title,
    required this.Description,
    required this.Address,
    required this.Salary,
    required this.Vacancies,
    required this.Type,
    required this.WorkingTimes,
    required this.Status,
    required this.PostedAt,
    required this.ExpiredAt,
    required this.Level,
    this.DeletedAt,
    required this.Recruiter,
  });

  factory cJobs_recruiter.fromJson(Map<String, dynamic> json) {
    return cJobs_recruiter(
      ID: json['ID'],
      Title: json['Title'],
      Description: json['Description'],
      Address: json['Address'],
      Salary: json['Salary'],
      Vacancies: json['Vacancies'],
      Type: json['Type'],
      WorkingTimes: json['WorkingTimes'],
      Status: json['Status'],
      PostedAt: DateTime.parse(json['PostedAt']),
      ExpiredAt: DateTime.parse(json['ExpiredAt']),
      Level: json['Level'],
      DeletedAt: json['DeletedAt'],
      Recruiter: cRecruiterPost.fromJson(json['Recruiter']),
    );
  }
}