import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/Services/auth_provinces_service.dart';
import '../../Models/Companies.dart';
import '../../Models/CompanyLocations.dart';
import '../../Models/Provinces.dart';
import '../../Services/auth_companies_service.dart';
import '../../Services/auth_signout_service.dart';
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

  File? _logoImage;
  File? _oldLogoImage;
  Uint8List? _imageBytes;

  File? get logoImage => _logoImage;
  Uint8List? get imageBytes => _imageBytes;
  File? get oldLogoImage => _oldLogoImage;

  Future<File> downloadImageAsFile(String imageUrl, String fileName) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception('Tải ảnh thất bại: ${response.statusCode}');
    }
  }

  void downloadImage(String imageUrl) async {
    try {
      _logoImage = await downloadImageAsFile(imageUrl, imageUrl.split('/').last);
      print('Đã tải và lưu tại: ${_logoImage!.path}');
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải ảnh: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _logoImage = File(pickedFile.path);
      notifyListeners();
    }
  }

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
    if (profileViewModel.recruiterInfo!.Company.LogoUrl != null) {
      downloadImage(profileViewModel.recruiterInfo!.Company.LogoUrl!);
    }
    _oldLogoImage = _logoImage;
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
    cCompany_RecruiterInfo? response = await CompanyService().editCompany(
      companyId: profileViewModel.recruiterInfo!.Company.ID!,
      newName: nameController.text,
      newDescription: descriptionController.text,
      newWebsiteUrl: websiteURLController.text,
      context: context,
      file: logoImage!
    );
    if (response != null) {
      profileViewModel.recruiterInfo!.Company = response;
      profileViewModel.notifyListeners();
    }
  }

  Future<bool> addBranch(BuildContext context) async {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(
      context,
      listen: false,
    );
    var response = await AuthCompaniesService().addBranch(
      companyId: profileViewModel.recruiterInfo!.Company.ID!,
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
                : profileViewModel.recruiterInfo!.Company.ID!,
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
