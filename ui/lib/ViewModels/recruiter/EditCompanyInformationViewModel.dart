import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Services/auth_provinces_service.dart';
import '../../Models/CompanyLocations.dart';
import '../../Models/Provinces.dart';
import '../../Services/auth_companies_service.dart';
import '../../Services/company_service.dart';
import 'ProfileViewModel.dart';

class EditCompanyInformationViewModel extends ChangeNotifier {
  late final TextEditingController _nameController;
  late final TextEditingController _websiteURLController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _branchNameController;
  late final TextEditingController _branchAddressController;
  late List<cProvinces> _provinceList = [];
  String? _provinceSelected;

  TextEditingController get nameController => _nameController;

  TextEditingController get websiteURLController => _websiteURLController;

  TextEditingController get descriptionController => _descriptionController;

  TextEditingController get branchNameController => _branchNameController;

  TextEditingController get branchAddressController => _branchAddressController;

  List<cProvinces> get provinceList => _provinceList;

  String? get provinceSelected => _provinceSelected;

  EditCompanyInformationViewModel(BuildContext context) {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(context);
    AuthProvincesService().getProvinces().then((value) {
      if (value.success) {
        _provinceList = value.data;
        _provinceList.sort((a, b) {
          String nameA =
              a.name
                  .replaceFirst(RegExp(r'^(Tỉnh|Thành phố)\s+'), '')
                  .toLowerCase();
          String nameB =
              b.name
                  .replaceFirst(RegExp(r'^(Tỉnh|Thành phố)\s+'), '')
                  .toLowerCase();
          return removeVietnameseAccentsRegex(
            nameA,
          ).compareTo(removeVietnameseAccentsRegex(nameB));
        });
      }
    });
    _nameController = TextEditingController(
      text: profileViewModel.recruiterInfo!.Company.Name,
    );
    _websiteURLController = TextEditingController(
      text: profileViewModel.recruiterInfo!.Company.WebsiteUrl,
    );
    _descriptionController = TextEditingController(
      text: profileViewModel.recruiterInfo!.Company.Description,
    );
    _branchAddressController = TextEditingController();
    _branchNameController = TextEditingController();
  }

  void setSelectedProvince(String? value) {
    _provinceSelected = value;
  }

  void clear() {
    branchAddressController.clear();
    branchNameController.clear();
    _provinceSelected = null;
  }

  Future<void> editCompany(BuildContext context) async {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(
      context,
      listen: false,
    );
    await CompanyService().editCompany(
      companyId: profileViewModel.recruiterInfo!.Company.ID,
      newName: nameController.text,
      newDescription: descriptionController.text,
      newWebsiteUrl: websiteURLController.text,
      context: context,
    );
  }

  Future<bool> addBranch(BuildContext context) async {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(
      context,
      listen: false,
    );
    var response = await AuthCompaniesService().addBranch(
      companyId: profileViewModel.recruiterInfo!.Company.ID,
      branchName: branchNameController.text,
      address: branchAddressController.text,
      locationId: provinceSelected ?? "",
    );
    if (response.success) {
      branchAddressController.clear();
      branchNameController.clear();
      _provinceSelected = null;
      AuthCompaniesService()
          .fetchBranches(
            (profileViewModel.recruiterInfo == null)
                ? ""
                : profileViewModel.recruiterInfo!.Company.ID,
          )
          .then((value) {
            profileViewModel.branches = value.data;
            profileViewModel.notifyListeners();
            return value;
          });
    }
    return response.success;
  }
}
