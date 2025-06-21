import 'package:flutter/material.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  List<Map<String, dynamic>> notifications = [
    {
      "ID": "f7f12038-d244-414d-b367-6594f19aa82b",
      "IsRead": false,
      "Content": [
        "Bài đăng mới: Frontend Developer (Junior)",
        "Tạo bởi: Công ty ABC",
        "Vào lúc: 09/04/2025 08:56:24 AM"
      ],
      "Metadata": {
        "jobId": "12bfb97c-a3d1-404c-8002-045e5417ef39",
        "jobTitle": "Frontend Developer (Junior)",
        "companyName": "Công ty ABC",
        "recruiterId": "a8631991-bac3-491b-a5d1-90d1acff95a2"
      },
      "CreatedAt": "2025-04-09T00:51:06.838"
    },
    {
      "ID": "97c2d084-9495-4fd8-9c4e-f5fd13351f43",
      "IsRead": false,
      "Content": [
        "Bài đăng mới: AI Engineer (Junior)",
        "Tạo bởi: Công ty ABC",
        "Vào lúc: 09/04/2025 08:56:24 AM"
      ],
      "Metadata": {
        "jobId": "aeb5e508-9c97-4cdd-98b5-8ec8d2b62e13",
        "jobTitle": "AI Engineer (Junior)",
        "companyName": "Công ty ABC",
        "recruiterId": "a8631991-bac3-491b-a5d1-90d1acff95a2"
      },
      "CreatedAt": "2025-04-09T00:56:45.876"
    },
  ];

  void _handleNotificationTap(Map<String, dynamic> noti) {
    setState(() {
      noti["IsRead"] = true;
    });

    // Show detail
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(noti["Content"][0] ?? "Chi tiết thông báo"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(noti["Content"][1]),
            const SizedBox(height: 4),
            Text(noti["Content"][2]),
            const SizedBox(height: 12),
            const Divider(),
            Text("Công ty: ${noti["Metadata"]["companyName"]}"),
            Text("Vị trí: ${noti["Metadata"]["jobTitle"]}"),
            Text("Mã công việc: ${noti["Metadata"]["jobId"]}"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Đóng"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notifications.isEmpty
          ? const Center(child: Text("Không có thông báo"))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final noti = notifications[index];
          final isRead = noti["IsRead"] == true;
          final content = noti["Content"] as List<dynamic>;

          return Dismissible(
            key: Key(noti["ID"]),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _deleteNotification(index),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: isRead ? Colors.white : const Color(0xFFE3F2FD),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Icon(
                  Icons.notifications,
                  color: isRead ? Colors.grey : Colors.blue,
                  size: 30,
                ),
                title: Text(
                  content[0],
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(content[1], style: const TextStyle(fontSize: 13)),
                    Text(content[2], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                onTap: () => _handleNotificationTap(noti),
              ),
            ),
          );
        },
      ),
    );
  }
}
