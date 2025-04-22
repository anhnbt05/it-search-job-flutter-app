import 'Companies.dart';
import 'Locations.dart';
import 'Recruiters.dart';

class cCompanyLocations {
  String? ID;
  String? BranchName;
  String? Address;
  DateTime? CreatedAt;
  DateTime? UpdatedAt;
  DateTime? DeletedAt;
  cCompanies? Company;
  cLocations? Location;
  List<cRecruiterPost>? Recruiters;
}

