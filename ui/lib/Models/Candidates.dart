import 'WorkExperiences.dart';


class cCandidates_cApplication_recruiter {
  final String ID;
  final String Bio;
  final String Level;
  final String? ResumeUrl;
  final List<String> Certifications;
  final String FullName;
  final String Email;
  final String PhoneNumber;
  final String AvatarUrl;
  final String Role;
  final List<cWorkExperiences> WorkExperiences;

  cCandidates_cApplication_recruiter({
    required this.ID,
    required this.Bio,
    required this.Level,
    required this.ResumeUrl,
    required this.Certifications,
    required this.FullName,
    required this.Email,
    required this.PhoneNumber,
    required this.AvatarUrl,
    required this.Role,
    required this.WorkExperiences,
  });

  factory cCandidates_cApplication_recruiter.fromJson(Map<String, dynamic> json) {
    return cCandidates_cApplication_recruiter(
      ID: json['ID'],
      Bio: json['Bio'],
      Level: json['Level'],
      ResumeUrl: json['ResumeUrl'].toString(),
      Certifications: List<String>.from(json['Certifications']),
      FullName: json['FullName'],
      Email: json['Email'],
      PhoneNumber: json['PhoneNumber'],
      AvatarUrl: json['AvatarUrl'].toString(),
      Role: json['Role'],
      WorkExperiences: (json['WorkExperiences'] as List)
          .map((e) => cWorkExperiences.fromJson(e))
          .toList(),
    );
  }
  cCandidates_cApplication_recruiter CopyCandidateInfor({
    String? newFullName,
    String? newPhoneNumber,
    String? newBio,
    String? newLevel,
    List<String>? newCertifications,
    String? newAvatarUrl,
    String? newResumeUrl,
  }) {
    return cCandidates_cApplication_recruiter(
      ID: ID,
      Bio: newBio ?? Bio,
      Level: newLevel ?? Level,
      ResumeUrl: newResumeUrl ?? ResumeUrl,
      Certifications: newCertifications ?? Certifications,
      FullName: newFullName ?? FullName,
      Email: Email,
      PhoneNumber: newPhoneNumber ?? PhoneNumber,
      AvatarUrl: newAvatarUrl ?? AvatarUrl,
      Role: Role,
      WorkExperiences: WorkExperiences,
    );
  }
  String get id => ID;
}

class Candidate_admin {
  final String ID;
  final String? ResumeUrl;
  final List<String> Certifications;
  final String Bio;
  final String Level;
  final String FullName;
  final String Email;
  final String PhoneNumber;
  final String AvatarUrl;
  final String Role;
  final List<Candidate_admin_WorkExperience> WorkExperiences;
  final String Status;
  final bool IsEmailVerified;
  final List<dynamic> Applications;

  Candidate_admin({
    required this.ID,
    required this.ResumeUrl,
    required this.Certifications,
    required this.Bio,
    required this.Level,
    required this.FullName,
    required this.Email,
    required this.PhoneNumber,
    required this.AvatarUrl,
    required this.Role,
    required this.WorkExperiences,
    required this.Status,
    required this.IsEmailVerified,
    required this.Applications,
  });

  factory Candidate_admin.fromJson(Map<String, dynamic> json) {
    return Candidate_admin(
      ID: json['ID'],
      ResumeUrl: json['ResumeUrl'],
      Certifications: List<String>.from(json['Certifications']),
      Bio: json['Bio'],
      Level: json['Level'],
      FullName: json['FullName'],
      Email: json['Email'],
      PhoneNumber: json['PhoneNumber'],
      AvatarUrl: json['AvatarUrl'],
      Role: json['Role'],
      WorkExperiences: (json['WorkExperiences'] as List)
          .map((e) => Candidate_admin_WorkExperience.fromJson(e))
          .toList(),
      Status: json['Status'],
      IsEmailVerified: json['IsEmailVerified'],
      Applications: json['Applications'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'ResumeUrl': ResumeUrl,
      'Certifications': Certifications,
      'Bio': Bio,
      'Level': Level,
      'FullName': FullName,
      'Email': Email,
      'PhoneNumber': PhoneNumber,
      'AvatarUrl': AvatarUrl,
      'Role': Role,
      'WorkExperiences': WorkExperiences.map((e) => e.toJson()).toList(),
      'Status': Status,
      'IsEmailVerified': IsEmailVerified,
      'Applications': Applications,
    };
  }
}

class Candidate_admin_WorkExperience {
  final String ID;
  final String? CompanyLogoUrl;
  final String CompanyName;
  final String Position;
  final String Location;
  final String JobType;
  final DateTime StartDate;
  final DateTime? EndDate;
  final List<String> Descriptions;

  Candidate_admin_WorkExperience({
    required this.ID,
    required this.CompanyLogoUrl,
    required this.CompanyName,
    required this.Position,
    required this.Location,
    required this.JobType,
    required this.StartDate,
    required this.EndDate,
    required this.Descriptions,
  });

  factory Candidate_admin_WorkExperience.fromJson(Map<String, dynamic> json) {
    return Candidate_admin_WorkExperience(
      ID: json['ID'],
      CompanyLogoUrl: json['CompanyLogoUrl'],
      CompanyName: json['CompanyName'],
      Position: json['Position'],
      Location: json['Location'],
      JobType: json['JobType'],
      StartDate: DateTime.parse(json['StartDate']),
      EndDate: json['EndDate'] != null ? DateTime.parse(json['EndDate']) : null,
      Descriptions: List<String>.from(json['Descriptions']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'CompanyLogoUrl': CompanyLogoUrl,
      'CompanyName': CompanyName,
      'Position': Position,
      'Location': Location,
      'JobType': JobType,
      'StartDate': StartDate.toIso8601String(),
      'EndDate': EndDate?.toIso8601String(),
      'Descriptions': Descriptions,
    };
  }
}
