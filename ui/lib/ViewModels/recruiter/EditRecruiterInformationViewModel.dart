import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Models/Enum.dart';
import 'package:ui/Models/ResponseModel.dart';
import 'package:ui/Services/api_service.dart';
import 'package:ui/Services/auth_resetpassword_service.dart';
import 'package:ui/Services/auth_verifyresetpasswordotp_service.dart';
import 'package:ui/Services/user_service.dart';

import '../../Constants/api_constants.dart';
import '../../Services/auth_forgetpassword_service.dart';
import '../login/SignInViewModel.dart';
import 'ProfileViewModel.dart';

class EditRecruiterInformationViewModel extends ChangeNotifier {
  late String userId;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _positionController;
  late final TextEditingController _otpController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmNewPasswordController;

  File? _avtImage;
  File? _oldAvtImage;
  Uint8List? _imageBytes;

  TextEditingController get fullNameController => _fullNameController;
  TextEditingController get phoneNumberController => _phoneNumberController;
  TextEditingController get positionController => _positionController;
  TextEditingController get otpController => _otpController;
  TextEditingController get newPasswordController => _newPasswordController;
  TextEditingController get confirmNewPasswordController => _confirmNewPasswordController;


  set otpController(TextEditingController value) {
    _otpController = value;
  }

  set newPasswordController(TextEditingController value) {
    _newPasswordController = value;
  }

  set confirmNewPasswordController(TextEditingController value) {
    _confirmNewPasswordController = value;
  }

  File? get avtImage => _avtImage;
  Uint8List? get imageBytes => _imageBytes;
  File? get oldAvtImage => _oldAvtImage;

  EditRecruiterInformationViewModel(BuildContext context, this.userId) {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(context);
    _fullNameController = TextEditingController(text: profileViewModel.recruiterInfo!.FullName);
    _phoneNumberController = TextEditingController(text: profileViewModel.recruiterInfo!.PhoneNumber);
    _positionController = TextEditingController(text: profileViewModel.recruiterInfo!.Position);
    _newPasswordController = TextEditingController();
    _confirmNewPasswordController = TextEditingController();
    _otpController = TextEditingController();
    downloadImage(profileViewModel.recruiterInfo!.AvatarUrl);
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
      print('Đã tải và lưu tại: ${_avtImage!.path}');
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

  Future<void> updateRecruiterInfo(BuildContext context, String userId) async {
    var authViewModel = Provider.of<SignInViewModel>(context, listen: false);
    var recruiterVM = Provider.of<RecruiterProfileViewModel>(context, listen: false);
    String? newAvtUrl = await UserService().patchRecruiterInfo(
      userId: userId,
      updateRecruiterDto: {"Position": positionController.text},
      file: avtImage!,
      newName: fullNameController.text,
      newPhoneNumber: phoneNumberController.text,
      context: context
    );
    if (newAvtUrl != null) {
      recruiterVM.recruiterInfo = recruiterVM.recruiterInfo!.CopyRecruiterInfor(newFullName: fullNameController.text, newPhoneNumber: phoneNumberController.text, newPosition: positionController.text, newAvatarUrl: newAvtUrl, Status: "active");
      recruiterVM.notifyListeners();
      notifyListeners();
    }
  }

  Future<ResponseModel> resetPassword(context) async {
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(context, listen: false);
    return await AuthResetpasswordService().resetPassword(profileViewModel.recruiterInfo!.Email, newPasswordController.text);
  }

  Future<ResponseModel> verifyOTP(context) async {
    notifyListeners();
    var profileViewModel = Provider.of<RecruiterProfileViewModel>(context, listen: false);
    return await AuthVerifyResetPasswordOtpService().verifyResetPasswordOtp(profileViewModel.recruiterInfo!.Email, otpController.text);

  }
}