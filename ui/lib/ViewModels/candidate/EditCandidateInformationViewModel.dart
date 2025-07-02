import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/Services/user_service.dart';

import '../../Helpers/toastification.dart';
import '../../Models/Enum.dart';
import '../../Services/auth_resetpassword_service.dart';
import '../../Services/auth_verifyresetpasswordotp_service.dart';
import '../AuthViewModel.dart';
import 'ProfileCandidateViewModel.dart';

class EditCandidateInformationViewModel extends ChangeNotifier {
  String getLevelName(eLevel? level) {
    switch (level) {
      case eLevel.intern:
        return "Intern";
      case eLevel.fresher:
        return "Fresher";
      case eLevel.mid:
        return "Mid";
      case eLevel.junior:
        return "Junior";
      case eLevel.senior:
        return "Senior";
      default:
        return level.toString().split('.').last;
    }
  }

  late String userId;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _bioController;
  late final TextEditingController _levelController;
  List<TextEditingController> _certificationControllers = [];
  late final TextEditingController _otpController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;

  File? _avtImage;
  File? _oldAvtImage;
  File? _CVFile;
  File? _oldCVFile;
  Uint8List? _imageBytes;

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get bioController => _bioController;
  TextEditingController get levelController => _levelController;
  List<TextEditingController> get certificationControllers =>
      _certificationControllers;
  TextEditingController get otpController => _otpController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmNewPasswordController =>
      _confirmNewPasswordController;

  File? get avtImage => _avtImage;
  File? get CVFile => _CVFile;
  Uint8List? get imageBytes => _imageBytes;
  File? get oldAvtImage => _oldAvtImage;
  File? get oldCVFile => _oldCVFile;

  EditCandidateInformationViewModel(BuildContext context, this.userId) {
    final profileVM = Provider.of<ProfileCandidateViewModel>(
      context,
      listen: false,
    );
    final info = profileVM.candidate;
    if (info?.Level != null) {
      levelSelected = eLevel.values.firstWhere(
        (e) => getLevelName(e).toLowerCase() == info?.Level?.toLowerCase(),
        orElse: () => eLevel.intern,
      );
    }
    if (info == null) {
      throw Exception(
        'Candidate info is null. Make sure it is loaded before using this ViewModel.',
      );
    }
    _fullNameController = TextEditingController(text: info.FullName);
    _phoneNumberController = TextEditingController(text: info.PhoneNumber);
    _bioController = TextEditingController(text: info.Bio ?? '');
    _levelController = TextEditingController(text: info.Level ?? '');
    _certificationControllers =
        (info.Certifications ?? [])
            .map((cert) => TextEditingController(text: cert))
            .toList();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _otpController = TextEditingController();
    downloadImage(info.AvatarUrl);
    _oldAvtImage = _avtImage;
    _oldCVFile = _CVFile;
  }

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
      _avtImage = await downloadImageAsFile(imageUrl, imageUrl.split('/').last);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải ảnh: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      _avtImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> pickCVFile() async {
    final result = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Documents', extensions: ['pdf', 'docx']),
      ],
    );
    if (result != null) {
      _CVFile = File(result.path);
      notifyListeners();
    }
  }

  Future<void> updateCandidateInfo(BuildContext context) async {
    final profileVM = Provider.of<ProfileCandidateViewModel>(
      context,
      listen: false,
    );
    final currentCandidate = profileVM.candidate!;

    try {
      final updateData = <String, dynamic>{};

      if (bioController.text != currentCandidate.Bio) {
        updateData['Bio'] = bioController.text;
      }

      if (levelSelected != null) {
        updateData['Level'] = levelSelected.toString().split('.').last;
      }

      final currentCerts = currentCandidate.Certifications ?? [];
      final newCerts =
          _certificationControllers
              .map((c) => c.text.trim())
              .where((c) => c.isNotEmpty)
              .toList();

      if (!_areListsEqual(currentCerts, newCerts)) {
        updateData['Certifications'] = newCerts;
      }

      bool hasAvatarChanged = avtImage?.path != _oldAvtImage?.path;
      bool hasCVChanged = CVFile?.path != _oldCVFile?.path;
      bool hasBasicChanged =
          fullNameController.text != currentCandidate.FullName ||
          phoneNumberController.text != currentCandidate.PhoneNumber;

      if (updateData.isNotEmpty ||
          hasAvatarChanged ||
          hasCVChanged ||
          hasBasicChanged) {
        final currentUserId =
            Provider.of<AuthViewModel>(context, listen: false).userId;
        String? response = await UserService().patchCandidateInfo(
          userId: currentUserId!,
          updateCandidateDto: updateData,
          fileAvatar: hasAvatarChanged ? avtImage : null,
          fileCV: hasCVChanged ? CVFile : null,
          newName: fullNameController.text,
          newPhoneNumber: phoneNumberController.text,
          context: context,
        );

        if (response != null) {
          profileVM.candidate = currentCandidate.CopyCandidateInfor(
            newFullName: fullNameController.text,
            newPhoneNumber: phoneNumberController.text,
            newBio: updateData['Bio'] ?? currentCandidate.Bio,
            newLevel: updateData['Level'] ?? currentCandidate.Level,
            newCertifications:
                updateData['Certifications'] ?? currentCandidate.Certifications,
            newAvatarUrl:
                hasAvatarChanged ? response : currentCandidate.AvatarUrl,
            newResumeUrl: hasCVChanged ? response : currentCandidate.ResumeUrl,
          );

          _oldAvtImage = avtImage;
          _oldCVFile = CVFile;

          profileVM.notifyListeners();
        }
      } else {
        showErrorToastification(
          title: "Thông báo",
          message: "Không có thay đổi nào để cập nhật",
        );
      }
    } catch (e) {
      showErrorToastification(
        title: "Lỗi",
        message: "Có lỗi xảy ra khi cập nhật: ${e.toString()}",
      );
    }
  }

  bool _areListsEqual(List<String>? list1, List<String>? list2) {
    if (list1 == null && list2 == null) return true;
    if (list1 == null || list2 == null) return false;
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<ResponseModel> resetPassword(BuildContext context) async {
    final profileVM = Provider.of<ProfileCandidateViewModel>(
      context,
      listen: false,
    );
    return await AuthResetpasswordService().resetPassword(
      profileVM.candidate!.Email,
      newPasswordController.text,
    );
  }

  Future<ResponseModel> verifyOTP(BuildContext context) async {
    final profileVM = Provider.of<ProfileCandidateViewModel>(
      context,
      listen: false,
    );
    if (profileVM.candidate == null) {
      profileVM.fetchCandidateInfo(context: context);
    }
    return await AuthVerifyResetPasswordOtpService().verifyResetPasswordOtp(
      profileVM.candidate!.Email,
      otpController.text,
    );
  }

  void addCertification() {
    _certificationControllers.add(TextEditingController());
    notifyListeners();
  }

  void removeCertification(int index) {
    if (index >= 0 && index < _certificationControllers.length) {
      _certificationControllers.removeAt(index);
      notifyListeners();
    }
  }

  eLevel? levelSelected;
  Color levelBorderColor = Colors.grey.shade400;

  void setLevelSelected(eLevel? level) {
    levelSelected = level;
    notifyListeners();
  }

  void setLevelBorderColor(Color color) {
    levelBorderColor = color;
    notifyListeners();
  }
}
