import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/toastification.dart';

import '../Models/Recruiters.dart';
import '../ViewModels/login/SignInViewModel.dart';
import 'api_service.dart';


// temporary
class UserService {
  final ApiService _apiService = ApiService();

  Future<cRecruiters?> getRecruiterInfo(
      {required String Id, required String accessToken, required SignInViewModel authViewModel}) async {
    try {
      if (await authViewModel.isAccessTokenExpired()) {
        await authViewModel.refreshAccessToken();
        accessToken = (await APIConstants.storage.read(key: 'accessToken'))!;
      }
      final response = await _apiService.getWithToken(
        accessToken: accessToken,
        endpoint: '${APIConstants.getUser_endpoint}/$Id',);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        return cRecruiters.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<String?> patchRecruiterInfo({
    required String accessToken,
    required String userId,
    required Map<String, dynamic> updateRecruiterDto,
    required File file,
    required String newName,
    required String newPhoneNumber,
    required SignInViewModel authViewModel,
  }) async {
    try {
      if (await authViewModel.isAccessTokenExpired()) {
        await authViewModel.refreshAccessToken();
        accessToken = (await APIConstants.storage.read(key: 'accessToken'))!;
      }
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse("${APIConstants.baseUrl}/users/$userId"),
      );
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['updateRecruiterDto'] = jsonEncode(updateRecruiterDto);
      request.fields['FullName'] = newName;
      request.fields['PhoneNumber'] = newPhoneNumber;

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatarFile',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        showSuccessToastification(title: "Hoàn tất", message: "Cập nhật thông tin của người dùng thành công");
        final decoded = jsonDecode(responseString);
        print(decoded);
        return decoded['AvatarUrl'];
      } else {
        showErrorToastification(title: "Lỗi", message: responseString);
        return null;
      }
    } catch (e) {
      showErrorToastification(title: "Lỗi", message: e.toString());
      print("mv");
      return null;
    }
  }
}