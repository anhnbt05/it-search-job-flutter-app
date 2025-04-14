import 'Applications.dart';
import 'Enum.dart';
import 'JobFavorites.dart';
import 'Users.dart';
import 'WorkExperiences.dart';

class cCandidates {
  String? ID;
  String? ResumeUrl;
  List<String>? Certifications;
  String? Bio;
  eLevel? Level;
  DateTime? DeletedAt;
  String? UserID;
  cUsers? User;
  List<cApplications>? Applications;
  List<cJobFavorites>? JobFavorites;
  List<cWorkExperiences>? WorkExperiences;
}
