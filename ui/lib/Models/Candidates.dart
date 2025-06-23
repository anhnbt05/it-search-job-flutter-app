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

