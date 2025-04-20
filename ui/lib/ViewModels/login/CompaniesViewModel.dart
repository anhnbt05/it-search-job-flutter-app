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
  }) async {
    return await _service.addBranch(
      companyId: companyId,
      branchName: branchName,
      address: address,
    );
  }
}
