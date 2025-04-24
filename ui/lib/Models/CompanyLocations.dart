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
  String? CompanyID;
  String? LocationID;

  cCompanyLocations({
    this.ID,
    this.BranchName,
    this.Address,
    this.CreatedAt,
    this.UpdatedAt,
    this.DeletedAt,
    this.CompanyID,
    this.LocationID,
  });

  factory cCompanyLocations.fromJson(Map<String, dynamic> json) {
    return cCompanyLocations(
      ID: json['ID']?.toString(),
      BranchName: json['BranchName'],
      Address: json['Address'],
      CreatedAt: json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : null,
      UpdatedAt: json['UpdatedAt'] != null ? DateTime.parse(json['UpdatedAt']) : null,
      DeletedAt: json['DeletedAt'] != null ? DateTime.tryParse(json['DeletedAt']) : null,
      CompanyID: json['CompanyID']?.toString(),
      LocationID: json['LocationID']?.toString(),
    );
  }
  cCompanies? Company;
  cLocations? Location;
  List<cRecruiterPost>? Recruiters;
}

