import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Helpers/toastification.dart';
import '../../Models/UserNotifications.dart';
import '../../ViewModels/candidate/CandidateNotificationViewModel.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initNotifications();
    }
  }

  Future<void> _initNotifications() async {
    final viewModel = Provider.of<CandidateNotificationViewModel>(context, listen: false);
    await viewModel.initialize(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CandidateNotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initNotifications(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có thông báo nào', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return _buildNotificationList(viewModel);
        },
      ),
    );
  }

  Widget _buildNotificationList(CandidateNotificationViewModel viewModel) {
    return ListView.separated(
      padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
      itemCount: viewModel.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final notification = viewModel.notifications[index];
        return _buildNotificationItem(context, notification);
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, UserNotification notification) {
    final isRead = notification.IsRead ?? false;

    return Dismissible(
      key: Key(notification.ID ?? 'key_${notification.hashCode}'),
      background: _buildDismissibleBackground(),
      dismissThresholds: const {DismissDirection.endToStart: 0.5},
      confirmDismiss: (direction) => _showDeleteConfirmationDialog(context),
      onDismissed: (direction) => _handleNotificationDeletion(context, notification),
      child: Container(
        decoration: BoxDecoration(
          color: isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRead ? Colors.grey.withOpacity(0.2) : Colors.blue[100]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            Icons.notifications,
            color: isRead ? Colors.grey : Colors.blue[700],
          ),
          title: Text(
            notification.Notification?.Title ?? 'Thông báo',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isRead ? Colors.grey[700] : Colors.black,
            ),
          ),
          subtitle: _buildNotificationSubtitle(notification),
          onTap: () => _handleNotificationTap(context, notification),
        ),
      ),
    );
  }

  Widget _buildNotificationSubtitle(UserNotification notification) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.access_time, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              _formatNotificationDate(notification.CreatedAt),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDismissibleBackground() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
    color: Colors.red,
    borderRadius: BorderRadius.circular(8),
    ),
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _handleNotificationDeletion(BuildContext context, UserNotification notification) {
    final viewModel = Provider.of<CandidateNotificationViewModel>(context, listen: false);
    viewModel.deleteNotification(context, notification.ID!);
    showSuccessToastification(title: "Thành công", message: "Đã xoá thông báo");
  }

  void _handleNotificationTap(BuildContext context, UserNotification notification) {
    final viewModel = Provider.of<CandidateNotificationViewModel>(context, listen: false);
    viewModel.markAsRead(context, notification.ID!);
    _showNotificationDetail(context, notification);
  }

  void _showNotificationDetail(BuildContext context, UserNotification notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => NotificationDetailSheet(notification: notification),
      isScrollControlled: true,
    );
  }

  String _formatNotificationDate(DateTime? date) {
    if (date == null) return '';
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dateFormat.format(date)}, ${timeFormat.format(date)}';
  }
}

class NotificationDetailSheet extends StatelessWidget {
  final UserNotification notification;

  const NotificationDetailSheet({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final content = notification.Content ?? [];
    final notificationData = notification.Notification;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDragHandle(),
            const SizedBox(height: 16),
            _buildNotificationTitle(notificationData?.Title),
            const SizedBox(height: 16),
            if (content.isNotEmpty) ..._buildContentLines(content),
            const SizedBox(height: 16),
            _buildNotificationTime(notification.CreatedAt),
            const SizedBox(height: 24),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildNotificationTitle(String? title) {
    return Text(
      title ?? 'Thông báo',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  List<Widget> _buildContentLines(List<String> content) {
    return content.map((line) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(line, style: const TextStyle(fontSize: 15)),
    )).toList();
  }

  Widget _buildNotificationTime(DateTime? date) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatDate(date),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Text('Đóng', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dateFormat.format(date)}, ${timeFormat.format(date)}';
  }
}