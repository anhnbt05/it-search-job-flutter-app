import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:ui/Constants/api_constants.dart';
import 'package:ui/Helpers/helpers.dart';
import 'package:ui/Services/notification_service.dart';
import 'package:ui/ViewModels/recruiter/CandidatesAppliesViewModel.dart';

import '../../Models/ResponseModel.dart';
import '../../Models/UserNotifications.dart';
import '../../Services/job_service.dart';
import '../../Services/websocket_service.dart';
import '../AuthViewModel.dart';
import 'PostedJobsManagementViewModel.dart';

class RecruiterNotificationViewModel extends ChangeNotifier {
  WebSocketService webSocketService = WebSocketService();

  List<UserNotification>? _notifications;
  List<UserNotification>? get notifications => _notifications;
  late Future<List<UserNotification>?> notificationsF;

  RecruiterNotificationViewModel(BuildContext context) {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    webSocketService.connect("${APIConstants.baseUrl}/websockets/gateway", loginVM.userId!, (data) {
      if (data == null) {
        var applicationVM = Provider.of<CandidatesAppliesViewModel>(context, listen: false);
        applicationVM.loadWithoutContext();
      } else {
      UserNotification newNoti = UserNotification.fromJson(data);
        _notifications!.insert(0, newNoti);
        notifyListeners();
        if (newNoti.Notification.Type == 'recruiter_job_approved' ||
            newNoti.Notification.Type == 'recruiter_job_rejected' ||
            newNoti.Notification.Type == 'recruiter_job_expired') {
          var jobVM = Provider.of<PostedJobsManagementViewModel>(
              context, listen: false);
          jobVM.loadWithoutContext();
        } else if (newNoti.Notification.Type == 'recruiter_new_application') {
          var applicationVM = Provider.of<CandidatesAppliesViewModel>(
              context, listen: false);
          applicationVM.loadWithoutContext();
        }
      }
    },);
    notificationsF = NotificationService().getNotifications(context, loginVM.userId!).then((value) {
      _notifications = value.data;
      notifyListeners();
      return value.data;
    });
  }

  Future<void> delete(BuildContext context, String notificationId) async {
    _notifications!.removeWhere((n) => n.ID == notificationId);
    notifyListeners();
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    await NotificationService().deleteNotification(context, loginVM.userId!, notificationId);
  }

  Future<void> read(BuildContext context, String notificationId) async {
    final index = _notifications!.indexWhere((n) => n.ID == notificationId);
    if (index != -1) {
      _notifications![index].IsRead = true;
      notifyListeners();
    }
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    await NotificationService().readNotification(context, loginVM.userId!, notificationId);
  }
}