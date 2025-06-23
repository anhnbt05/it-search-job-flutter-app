import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Services/notification_service.dart';

import '../../Models/ResponseModel.dart';
import '../../Models/UserNotifications.dart';
import '../../Services/websocket_service.dart';
import '../AuthViewModel.dart';

class NotificationViewModel extends ChangeNotifier {
  WebSocketService webSocketService = WebSocketService();

  late List<UserNotification> notifications;
  late Future<List<UserNotification>?> notificationsF;

  NotificationViewModel(BuildContext context) {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    webSocketService.connect("${APIConstants.baseUrl}/websockets/gateway", loginVM.userId!, (data) {
      var newNoti = UserNotification.fromJson(data);
      notifications.insert(0, newNoti);
      notifyListeners();
    },);
    notificationsF = NotificationService().getNotifications(context, loginVM.userId!).then((value) {
      notifications = value.data;
      notifyListeners();
      return value.data;
    });
  }
}