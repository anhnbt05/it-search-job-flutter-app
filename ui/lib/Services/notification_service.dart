import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../Constants/api_constants.dart';
import '../Helpers/helpers.dart';
import '../Models/ResponseModel.dart';
import '../Models/UserNotifications.dart';

class NotificationService {
  Future<ResponseModel> getNotifications(BuildContext context, String userId) async {
    var validToken = await getValidAccessToken(context);

    var response = await http.get(
      Uri.parse("${APIConstants.baseUrl}/users/$userId/notifications"),
      headers: {
        'Authorization': 'Bearer $validToken',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<UserNotification> notifications =
      (decoded as List).map((e) => UserNotification.fromJson(e)).toList();

      return ResponseModel(
        success: true,
        message: "Lấy thông báo thành công",
        messageList: ["Lấy thông báo thành công"],
        data: notifications,
      );
    } else {
      String message = 'Đã xảy ra lỗi';
      List<String> messageList = [];

      if (decoded is Map && decoded['message'] != null) {
        if (decoded['message'] is String) {
          message = decoded['message'];
          messageList = [decoded['message']];
        } else if (decoded['message'] is List) {
          messageList = (decoded['message'] as List)
              .map((e) => e is String ? e : e.toString())
              .toList();
          message = messageList.join(' - ');
        }
      }

      return ResponseModel(
        success: false,
        message: message,
        messageList: messageList,
        data: null,
      );
    }
  }

  Future<ResponseModel> readNotification(BuildContext context, String userId, String notificationId) async {
    var validToken = await getValidAccessToken(context);
    var response = await http.get(
      Uri.parse("${APIConstants.baseUrl}/users/$userId/notifications/$notificationId"),
      headers: {
        'Authorization': 'Bearer $validToken',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final UserNotification notifications = UserNotification.fromJson(decoded);

      return ResponseModel(
        success: true,
        message: "Lấy thông báo thành công",
        messageList: ["Lấy thông báo thành công"],
        data: notifications,
      );
    } else {
      String message = 'Đã xảy ra lỗi';
      List<String> messageList = [];

      if (decoded is Map && decoded['message'] != null) {
        if (decoded['message'] is String) {
          message = decoded['message'];
          messageList = [decoded['message']];
        } else if (decoded['message'] is List) {
          messageList = (decoded['message'] as List)
              .map((e) => e is String ? e : e.toString())
              .toList();
          message = messageList.join(' - ');
        }
      }

      return ResponseModel(
        success: false,
        message: message,
        messageList: messageList,
        data: null,
      );
    }
  }

  Future<ResponseModel> deleteNotification(BuildContext context, String userId, String notificationId) async {
    var validToken = await getValidAccessToken(context);
    var response = await http.delete(
      Uri.parse("${APIConstants.baseUrl}/users/$userId/notifications/$notificationId"),
      headers: {
        'Authorization': 'Bearer $validToken',
        'Content-Type': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<UserNotification> notifications =
      (decoded as List).map((e) => UserNotification.fromJson(e)).toList();

      return ResponseModel(
        success: true,
        message: "Xóa thông báo thành công",
        messageList: ["Xóa thông báo thành công"],
        data: notifications,
      );
    } else {
      String message = 'Đã xảy ra lỗi';
      List<String> messageList = [];

      if (decoded is Map && decoded['message'] != null) {
        if (decoded['message'] is String) {
          message = decoded['message'];
          messageList = [decoded['message']];
        } else if (decoded['message'] is List) {
          messageList = (decoded['message'] as List)
              .map((e) => e is String ? e : e.toString())
              .toList();
          message = messageList.join(' - ');
        }
      }

      return ResponseModel(
        success: false,
        message: message,
        messageList: messageList,
        data: null,
      );
    }
  }
}