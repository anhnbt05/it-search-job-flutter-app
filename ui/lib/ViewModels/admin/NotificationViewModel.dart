import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/helpers.dart';

import '../../Models/ResponseModel.dart';
import '../../Models/UserNotifications.dart';
import '../../Services/websocket_service.dart';
import '../AuthViewModel.dart';

class NotificationViewModel extends ChangeNotifier {
  WebSocketService webSocketService = WebSocketService();
  Future<List<AdminNotification>> getNotifications(BuildContext context, String userId) async {
    var validToken = await getValidAccessToken(context);

    var response = await http.get(
      Uri.parse("${APIConstants.baseUrl}/users/$userId/notifications"),
      headers: {
        'Authorization': 'Bearer $validToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawData = jsonDecode(response.body);
      final List<AdminNotification> notifications =
      rawData.map((e) => AdminNotification.fromJson(e)).toList();

      return notifications;
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  late List<AdminNotification> notifications;
  late Future<List<AdminNotification>?> notificationsF;

  NotificationViewModel(BuildContext context) {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    webSocketService.connect("${APIConstants.baseUrl}/websockets/gateway", loginVM.userId!, (data) {
      var newNoti = AdminNotification.fromJson(data);
      notifications.insert(0, newNoti);
      notifyListeners();
    },);
    notificationsF = getNotifications(context, loginVM.userId!).then((value) {
      notifications = value;
      notifyListeners();
      return value;
    });
  }
}