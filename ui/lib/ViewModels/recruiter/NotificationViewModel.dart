import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
      if (newNoti.Notification.Type == 'recruiter_job_approved' || newNoti.Notification.Type == 'recruiter_job_rejected' || newNoti.Notification.Type == 'recruiter_job_expired') {
        var jobVM = Provider.of<PostedJobsManagementViewModel>(context, listen: false);
        jobVM.loadWithoutContext();
      } else if (newNoti.Notification.Type == 'recruiter_new_application') {
        var applicationVM = Provider.of<CandidatesAppliesViewModel>(context, listen: false);
        applicationVM.loadWithoutContext();
      }
    },);
    notificationsF = NotificationService().getNotifications(context, loginVM.userId!).then((value) {
      notifications = value.data;
      notifyListeners();
      return value.data;
    });
  }

  Future<void> delete(BuildContext context, String notificationId) async {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    await NotificationService().deleteNotification(context, loginVM.userId!, notificationId);
  }

  Future<void> read(BuildContext context, String notificationId) async {
    var loginVM = Provider.of<AuthViewModel>(context, listen: false);
    await NotificationService().readNotification(context, loginVM.userId!, notificationId);
  }
}