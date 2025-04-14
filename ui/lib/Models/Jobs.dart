import 'Applications.dart';
import 'Enum.dart';
import 'JobBenefits.dart';
import 'JobCategories.dart';
import 'JobDescriptions.dart';
import 'JobFavorites.dart';
import 'JobRequirements.dart';
import 'Recruiters.dart';

class cJobs {
  String? ID;
  String? Title;
  String? Description;
  String? Address;
  String? Salary;
  int? Vacancies;
  eJobType? Type;
  String? WorkingTimes;
  eJobStatus? Status;
  DateTime? PostedAt;
  DateTime? ExpiredAt;
  eLevel? Level;
  DateTime? DeletedAt;
  String? RecruiterId;
  List<cApplications>? Applications;
  List<cJobDescriptions>? JobDescriptions;
  List<cJobFavorites>? JobFavorites;
  List<cJobRequirements>? jobRequirements;
  List<cJobBenefits>? JobBenefits;
  cRecruiters? Recruiter;
  List<cJobCategories>? JobCategories;
}
