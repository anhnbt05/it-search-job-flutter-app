import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/toastification.dart';
import 'package:ui/Models/ResponseModel.dart';

import '../Helpers/helpers.dart';
import '../Models/Recruiters.dart';
import '../Models/Users.dart';
import '../ViewModels/login/SignInViewModel.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<cRecruiters?> getRecruiterInfo(
      {required String Id, required BuildContext context}) async {
    try {
      final validToken = await getValidAccessToken(context);

      final response = await _apiService.getWithToken(
        accessToken: validToken!,
        endpoint: '${APIConstants.getUser_endpoint}/$Id',);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        cRecruiters r = cRecruiters.fromJson(data);
        return r;
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<cRecruiters?> getRecruiterInfo_admin(
      {required String Id, required BuildContext context}) async {
    try {
      final validToken = await getValidAccessToken(context);

      final response = await _apiService.getWithToken(
        accessToken: validToken!,
        endpoint: 'users?recruiterId=$Id',);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        cRecruiters r = cRecruiters.fromJson(data);
        return r;
      }
      return null;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<String?> patchRecruiterInfo({
    required String userId,
    required Map<String, dynamic> updateRecruiterDto,
    required File file,
    required String newName,
    required String newPhoneNumber,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse("${APIConstants.baseUrl}/users/$userId"),
      );
      request.headers['Authorization'] = 'Bearer $validToken';
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
      final decoded = jsonDecode(responseString);
      if (response.statusCode == 200) {
        showSuccessToastification(title: "Hoàn tất", message: "Cập nhật thông tin của người dùng thành công");
        return decoded['AvatarUrl'];
      } else {
        print(decoded);
        showErrorToastification(title: "Lỗi", message: decoded['message'][0]['message']);
        return null;
      }
    } catch (e) {
      showErrorToastification(title: "Lỗi", message: e.toString());
      return null;
    }
  }

  Future<List<cUsers>> getAllUser(BuildContext context) async {
    var validToken = await getValidAccessToken(context);

    final response = await http.get(
      Uri.parse('${APIConstants.baseUrl}/${APIConstants.getUser_admin_endpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $validToken',
      },
    );

    List<dynamic> userList = jsonDecode(response.body);
    List<cUsers> r = userList.map((e) => cUsers.fromJson(e)).toList();
    return r;
  }

  Future<bool> deleteUser(String userId, BuildContext context) async {
    var validToken = await getValidAccessToken(context);

    final url = Uri.parse('${APIConstants.baseUrl}/${APIConstants.deleteUser_endpoint}/$userId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $validToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      showErrorToastification(title: "Lỗi", message: jsonDecode(response.body)["message"]);
      return false;
    }
  }
}