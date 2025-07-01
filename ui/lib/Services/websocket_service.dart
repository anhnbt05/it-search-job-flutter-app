import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocketService {
  late IO.Socket _socket;

  void connect(String baseUrl, String userId, Function(dynamic) onNotificationReceived) {
    print('🔗 Kết nối tới Socket.IO: $baseUrl với userId=$userId');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Đã kết nối Socket.IO với WebSocket');
    });

    _socket.onDisconnect((_) {
      print('🔌 Socket.IO đã ngắt kết nối');
    });

    _socket.onConnectError((error) {
      print('❌ Lỗi kết nối Socket.IO: $error');
    });

    _socket.on('candidate_notification', (data) {
      print('📩 Nhận notification cho candidate: $data');
      onNotificationReceived(data);
    });

    _socket.on('recruiter_notification', (data) {
      print('📩 Nhận notification cho recruiter: $data');
      onNotificationReceived(data);
    });

    _socket.on('admin_notification', (data) {
      print('📩 Nhận notification cho admin: $data');
      onNotificationReceived(data);
    });

    _socket.on('candidate_delete_application', (data) {
      print('$data');
      onNotificationReceived(data);
    });
  }

  void disconnect() {
    _socket.disconnect();
    print('🔌 Ngắt kết nối Socket.IO');
  }
}