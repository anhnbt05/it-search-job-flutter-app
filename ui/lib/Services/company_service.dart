import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ui/Models/CompanyLocations.dart';

import '../Constants/api_constants.dart';
import '../Helpers/helpers.dart';
import '../Helpers/toastification.dart';
import '../Models/Companies.dart';

class CompanyService {
  Future<cCompany_RecruiterInfo?> editCompany({
    required String companyId,
    required newName,
    required newDescription,
    required newWebsiteUrl,
    required BuildContext context,
    required File file,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse("${APIConstants.baseUrl}/${APIConstants.patchCompany_endpoint}/${companyId}"),
      );
      request.headers['Authorization'] = 'Bearer $validToken';
      request.fields['WebsiteUrl'] = newWebsiteUrl;
      request.fields['Description'] = newDescription;
      request.fields['Name'] = newName;

      request.files.add(
        await http.MultipartFile.fromPath(
          'logoFile',
          file.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      print(responseString);
      final responseData = jsonDecode(responseString);
     /* final response = await _apiService.patchWithToken(
        endpoint: APIConstants.patchCompany_endpoint,
        body: {
          'Name': newName,
          'WebsiteUrl': newWebsiteUrl,
          'Description': newDescription,
        },
        accessToken: validToken!,
        Id: companyId,
      );*/
      if (response.statusCode == 200) {
        showSuccessToastification(
          title: 'Hoàn tất',
          message: 'Cập nhật thông tin công ty thành công',
        );
        return cCompany_RecruiterInfo.fromJson(responseData);
      } else {
        print("Failed to edit");
        showErrorToastification(
          title: 'Lỗi',
          message: responseData['message']['message'],
        );
        return null;
      }
    } catch (e) {
      print("Error: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
      return null;
    }
  }
}