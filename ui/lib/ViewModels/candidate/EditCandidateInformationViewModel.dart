import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/Services/user_service.dart';

import '../../Services/auth_resetpassword_service.dart';
import '../../Services/auth_verifyresetpasswordotp_service.dart';
import 'ProfileCandidateViewModel.dart';

class EditCandidateInformationViewModel extends ChangeNotifier {
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
  Uint8List? _imageBytes;

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get bioController => _bioController;
  TextEditingController get levelController => _levelController;
  List<TextEditingController> get certificationControllers => _certificationControllers;
  TextEditingController get otpController => _otpController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmNewPasswordController => _confirmNewPasswordController;

  File? get avtImage => _avtImage;
  Uint8List? get imageBytes => _imageBytes;
  File? get oldAvtImage => _oldAvtImage;

  EditCandidateInformationViewModel(BuildContext context, this.userId) {
    final profileVM = Provider.of<ProfileCandidateViewModel>(context, listen: false);
    final info = profileVM.candidate;
    if (info == null) {
      throw Exception('Candidate info is null. Make sure it is loaded before using this ViewModel.');
    }
    _fullNameController = TextEditingController(text: info.FullName);
    _phoneNumberController = TextEditingController(text: info.PhoneNumber);
    _bioController = TextEditingController(text: info.Bio ?? '');
    _levelController = TextEditingController(text: info.Level ?? '');
    _certificationControllers = (info.Certifications ?? []).map((cert) => TextEditingController(text: cert)).toList();
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _otpController = TextEditingController();
    downloadImage(info.AvatarUrl);
    _oldAvtImage = _avtImage;
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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _avtImage = File(pickedFile.path);
      notifyListeners();
    }
  }

  Future<void> updateCandidateInfo(BuildContext context, String userId) async {
    final profileVM = Provider.of<ProfileCandidateViewModel>(context, listen: false);
    final currentCandidate = profileVM.candidate!;

    String? newAvtUrl = await UserService().patchCandidateInfo(
      userId: userId,
      updateCandidateDto: {
        "Bio": bioController.text,
        "Level": levelController.text,
        "Certifications": _certificationControllers.map((c) => c.text.trim()).where((c) => c.isNotEmpty).toList(),
      },
      file: avtImage!,
      newName: fullNameController.text,
      newPhoneNumber: phoneNumberController.text,
      context: context,
    );

    if (newAvtUrl != null) {
      profileVM.candidate = currentCandidate.CopyCandidateInfor(
        newFullName: fullNameController.text,
        newPhoneNumber: phoneNumberController.text,
        newBio: bioController.text,
        newLevel: levelController.text,
        newCertifications: _certificationControllers.map((c) => c.text.trim()).where((c) => c.isNotEmpty).toList(),
        newAvatarUrl: newAvtUrl,
      );
      profileVM.notifyListeners();
      notifyListeners();
    }
  }

  Future<ResponseModel> resetPassword(BuildContext context) async {
    final profileVM = Provider.of<ProfileCandidateViewModel>(context, listen: false);
    return await AuthResetpasswordService().resetPassword(
      profileVM.candidate!.Email,
      newPasswordController.text,
    );
  }

  Future<ResponseModel> verifyOTP(BuildContext context) async {
    final profileVM = Provider.of<ProfileCandidateViewModel>(context, listen: false);
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
}
