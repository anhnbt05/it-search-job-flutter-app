import 'package:flutter/material.dart';
import '../../Models/Companies.dart';
import '../../Models/CompanyLocations.dart';
import '../../Services/auth_companies_service.dart';
import '../../Models/ResponseModel.dart';

class CompaniesViewModel extends ChangeNotifier {
  final AuthCompaniesService _service = AuthCompaniesService();

  List<cCompanies> companies = [];
  List<cCompanyLocations> branches = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchCompanies() async {
    isLoading = true;
    notifyListeners();

    final result = await _service.companies();
    if (result.success) {
      companies = result.data as List<cCompanies>;
      errorMessage = null;
    } else {
      errorMessage = result.message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBranches(String companyId) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.fetchBranches(companyId);
    if (result.success) {
      branches = result.data as List<cCompanyLocations>;
      errorMessage = null;
    } else {
      errorMessage = result.message;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<ResponseModel> addBranch({
    required String companyId,
    required String branchName,
    required String address,
    required String locationId,
  }) async {
    return await _service.addBranch(
      companyId: companyId,
      branchName: branchName,
      address: address,
      locationId: locationId,
    );
  }
  Future<ResponseModel> addCompany({
    required String name,
    required String websiteUrl,
    required String description,
    required String branchName,
    required String address,
    required String locationId,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await _service.addCompany(
      name: name,
      websiteUrl: websiteUrl,
      description: description,
      branchName: branchName,
      address: address,
      locationId: locationId,
    );

    isLoading = false;
    if (!result.success) errorMessage = result.message;
    notifyListeners();

    return result;
  }
}