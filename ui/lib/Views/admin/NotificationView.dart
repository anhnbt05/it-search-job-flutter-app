import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../Helpers/toastification.dart';
import '../../Models/UserNotifications.dart';
import '../../ViewModels/admin/AdminNotificationViewModel.dart';

Widget NotificationScreen(BuildContext context) {
  var viewModel = Provider.of<AdminNotificationViewModel>(context);
  if (viewModel.notifications == null) {
    return const Center(child: CircularProgressIndicator());
  }

  else if (viewModel.notifications!.isEmpty) {
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
}

Widget _buildNotificationList(AdminNotificationViewModel viewModel) {
  return ListView.separated(
    padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
    itemCount: viewModel.notifications!.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final notification = viewModel.notifications![index];
      return _buildNotificationItem(context, notification);
    },
  );
}

Widget _buildNotificationItem(BuildContext context,
    UserNotification notification) {
  final isRead = notification.IsRead ?? false;
  final notificationKey = notification.ID ?? 'key_${notification.hashCode}';

  final dragOffset = ValueNotifier<double>(0.0);
  final isDialogShowing = ValueNotifier<bool>(false);

  return ValueListenableBuilder<double>(
    valueListenable: dragOffset,
    builder: (context, offset, child) {
      return Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(offset, 0),
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (isDialogShowing.value) return;
                if (details.delta.dx < 0) {
                  dragOffset.value += details.delta.dx;
                  double maxDrag = -MediaQuery.of(context).size.width * 0.15;
                  if (dragOffset.value <= maxDrag) {
                    dragOffset.value = maxDrag;
                    if (!isDialogShowing.value) {
                      isDialogShowing.value = true;
                      _showDeleteConfirmationDialog(context).then((result) {
                        isDialogShowing.value = false;
                        if (result == true) {
                          _handleNotificationDeletion(context, notification);
                        }
                        dragOffset.value = 0.0;
                      });
                    }
                  }
                }
              },
              onHorizontalDragEnd: (details) {
                if (!isDialogShowing.value &&
                    dragOffset.value > -MediaQuery.of(context).size.width * 0.15) {
                  dragOffset.value = 0.0;
                }
              },
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
            ),
          ),
        ],
      );
    },
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

/*Widget _buildDismissibleBackground() {
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
}*/

Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) =>
        AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            "Xác nhận",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              fontFamily: 'Poppins'
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text('Bạn có chắc muốn xóa thông báo này?', style: TextStyle(fontFamily: 'Poppins'),),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: TextButton.styleFrom(
                overlayColor: Colors.transparent,
              ),
              child: Text(
                'Hủy',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Poppins'
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xee65c29c),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Đồng ý',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Poppins'
                ),
              ),
            ),
          ],
        )
  );
}

void _handleNotificationDeletion(BuildContext context,
    UserNotification notification) {
  final viewModel = Provider.of<AdminNotificationViewModel>(context, listen: false);
  viewModel.delete(context, notification.ID!);
  showSuccessToastification(title: "Thành công", message: "Đã xoá thông báo");
}

void _handleNotificationTap(BuildContext context,
    UserNotification notification) {
  final viewModel = Provider.of<AdminNotificationViewModel>(context, listen: false);
  viewModel.read(context, notification.ID!);
  _showNotificationDetail(context, notification);
}

void _showNotificationDetail(BuildContext context,
    UserNotification notification) {
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
    return content.map((line) =>
        Padding(
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