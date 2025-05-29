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
  final List<String> Categories;

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
    required this.Categories,
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
      Categories: List<String>.from(json['Categories']),
    );
  }

  cJobs_recruiter copyWith({String? status}) {
    return cJobs_recruiter(
      ID: ID,
      Title: Title,
      Description: Description,
      Address: Address,
      Salary: Salary,
      Vacancies: Vacancies,
      Type: Type,
      WorkingTimes: WorkingTimes,
      Status: status ?? Status,
      PostedAt: PostedAt,
      ExpiredAt: ExpiredAt,
      Level: Level,
      DeletedAt: 'DeletedAt',
      Recruiter: Recruiter,
      Categories: Categories,
    );
  }

  cJobs_recruiter copyAll({
    String? ID,
    String? Title,
    String? Description,
    String? Address,
    String? Salary,
    int? Vacancies,
    String? Type,
    String? WorkingTimes,
    String? Status,
    DateTime? PostedAt,
    DateTime? ExpiredAt,
    String? Level,
    List<String>? Categories,
    cRecruiterPost? Recruiter,
  }) {
    return cJobs_recruiter(
      ID: ID ?? this.ID,
      Title: Title ?? this.Title,
      Description: Description ?? this.Description,
      Address: Address ?? this.Address,
      Salary: Salary ?? this.Salary,
      Vacancies: Vacancies ?? this.Vacancies,
      Type: Type ?? this.Type,
      WorkingTimes: WorkingTimes ?? this.WorkingTimes,
      Status: Status ?? this.Status,
      PostedAt: PostedAt ?? this.PostedAt,
      ExpiredAt: ExpiredAt ?? this.ExpiredAt,
      Level: Level ?? this.Level,
      Categories: Categories ?? this.Categories,
      Recruiter: Recruiter ?? this.Recruiter,
    );
  }
}

class cJobs {
  final String ID;
  final String Title;
  final String? Description;
  final String Address;
  final String Salary;
  final int Vacancies;
  final String Type;
  final String WorkingTimes;
  final String Status;
  final DateTime PostedAt;
  final DateTime ExpiredAt;
  final String Level;
  final List<String> JobDescriptions;
  final List<String> JobBenefits;
  final List<String> JobRequirements;
  final List<String> Categories;
  final cRecruiter_Job Recruiter;
  final String? DeletedAt;
  cJobs({
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
    required this.JobDescriptions,
    required this.JobBenefits,
    required this.JobRequirements,
    required this.Categories,
    required this.Recruiter,
    this.DeletedAt,
  });

  factory cJobs.fromJson(Map<String, dynamic> json) {
    return cJobs(
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
      JobDescriptions: List<String>.from(json['JobDescriptions']),
      JobBenefits: List<String>.from(json['JobBenefits']),
      JobRequirements: List<String>.from(json['JobRequirements']),
      Categories: List<String>.from(json['Categories']),
      Recruiter: cRecruiter_Job.fromJson(json['Recruiter']),
      DeletedAt: json['DeletedAt'],
    );
  }
}