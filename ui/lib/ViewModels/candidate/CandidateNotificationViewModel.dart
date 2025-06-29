import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Constants/api_constants.dart';
import '../../Models/UserNotifications.dart';
import '../../Services/notification_service.dart';
import '../../Services/websocket_service.dart';
import '../AuthViewModel.dart';

class CandidateNotificationViewModel extends ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  final NotificationService _notificationService = NotificationService();

  List<UserNotification>? _notifications;
  bool _isLoading = false;
  String? _errorMessage;

  List<UserNotification>? get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CandidateNotificationViewModel(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    if (authVM.userId == null) {
      _errorMessage = 'Chưa đăng nhập';
      notifyListeners();
      return;
    }
    _setupWebSocket(context, authVM.userId!);
  }

  Future<void> initialize(BuildContext context) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    await _loadInitialNotifications(context, authVM.userId!);
  }

  Future<void> _loadInitialNotifications(BuildContext context, String userId) async {
    if (_notifications != null) return;
    try {
      _isLoading = true;

      final response = await _notificationService.getNotifications(context, userId);

      if (response.success) {
        _notifications = response.data as List<UserNotification>;
      } else {
        _errorMessage = response.message ?? 'Lỗi khi tải thông báo';
      }
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi khi tải thông báo: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupWebSocket(BuildContext context, String userId) {
    _webSocketService.connect(
      "${APIConstants.baseUrl}/websockets/gateway",
      userId,
          (data) {
        final newNotification = UserNotification.fromJson(data);
        _addNewNotification(newNotification);

        if (context.mounted) {
          _showNewNotificationSnackbar(context, newNotification);
        }
      },
    );
  }

  void _addNewNotification(UserNotification notification) {
    _notifications!.insert(0, notification);
    notifyListeners();
  }

  void _showNewNotificationSnackbar(BuildContext context, UserNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.Notification?.Title ?? 'Bạn có thông báo mới'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> markAsRead(BuildContext context, String notificationId) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final index = _notifications!.indexWhere((n) => n.ID == notificationId);
    if (index != -1) {
      _notifications![index].IsRead = true;
      notifyListeners();
    }
    await _notificationService.readNotification(context, authVM.userId!, notificationId);
  }

  Future<void> deleteNotification(BuildContext context, String notificationId) async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    _notifications!.removeWhere((n) => n.ID == notificationId);
    notifyListeners();
    await _notificationService.deleteNotification(context, authVM.userId!, notificationId);
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}