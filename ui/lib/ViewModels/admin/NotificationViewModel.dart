import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Services/notification_service.dart';

import '../../Models/ResponseModel.dart';
import '../../Models/UserNotifications.dart';
import '../../Services/job_service.dart';
import '../../Services/websocket_service.dart';
import '../AuthViewModel.dart';
import 'RecruimentApprovalViewModel.dart';

class NotificationViewModel extends ChangeNotifier {
  WebSocketService webSocketService = WebSocketService();

  List<UserNotification>? _notifications;
  List<UserNotification>? get notifications => _notifications;
  late Future<List<UserNotification>?> notificationsF;

  NotificationViewModel(BuildContext context) {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    webSocketService.connect("${APIConstants.baseUrl}/websockets/gateway", loginVM.userId!, (data) {
      var jobVM = Provider.of<RecruiterApprovalViewModel>(context, listen: false);
      var newNoti = UserNotification.fromJson(data);
      _notifications?.insert(0, newNoti);
      notifyListeners();
      jobVM.loadJobsWithoutContext();
    },);
    notificationsF = NotificationService().getNotifications(context, loginVM.userId!).then((value) {
      _notifications = value.data;
      notifyListeners();
      return value.data;
    });
  }

  Future<void> delete(BuildContext context, String notificationId) async {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    var response = await NotificationService().deleteNotification(context, loginVM.userId!, notificationId);

    if (response.success) {
      _notifications!.removeWhere((n) => n.ID == notificationId);
      notifyListeners();
    }
  }

  Future<void> read(BuildContext context, String notificationId) async {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    await NotificationService().readNotification(context, loginVM.userId!, notificationId);

    final index = _notifications!.indexWhere((n) => n.ID == notificationId);
    if (index != -1) {
      _notifications![index].IsRead = true;
      notifyListeners();
    }
  }
}