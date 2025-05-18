import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../Constants/api_constants.dart';
import '../Helpers/helpers.dart';
import '../Helpers/toastification.dart';
import 'api_service.dart';

class CompanyService {
  final _apiService = ApiService();

  Future<bool> editCompany({
    required String companyId,
    required newName,
    required newDescription,
    required newWebsiteUrl,
    required BuildContext context,
  }) async {
    try {
      final validToken = await getValidAccessToken(context);

      final response = await _apiService.patchWithToken(
        endpoint: APIConstants.patchCompany_endpoint,
        body: {
          'Name': newName,
          'WebsiteUrl': newWebsiteUrl,
          'Description': newDescription,
        },
        accessToken: validToken!,
        Id: companyId,
      );

      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        showSuccessToastification(
          title: 'Hoàn tất',
          message: responseData['message'],
        );
        return true;
      } else {
        print("Failed to edit job: ${response.body}");
        showErrorToastification(
          title: 'Lỗi',
          message: responseData['message'][0]['message'],
        );
        return false;
      }
    } catch (e) {
      print("Error: $e");
      showErrorToastification(title: 'Lỗi', message: e.toString());
      return false;
    }
  }
}