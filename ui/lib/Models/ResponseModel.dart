class ResponseModel {
  final bool success;
  final String message;
  final List<String> messageList;
  final dynamic data;

  ResponseModel({
    required this.success,
    required this.message,
    required this.messageList,
    this.data,
  });

  factory ResponseModel.fromJson(dynamic rawJson) {
    if (rawJson is String || rawJson is num) {
      final msg = rawJson.toString();
      return ResponseModel(
        success: false,
        message: msg,
        messageList: [msg],
        data: null,
      );
    }

    if (rawJson is List) {
      return ResponseModel(
        success: true,
        message: 'Thành công',
        messageList: ['Thành công'],
        data: rawJson,
      );
    }
    final Map<String, dynamic> json = Map<String, dynamic>.from(rawJson);

    String finalMessage = 'Lỗi không xác định';
    List<String> messages = [];
    if (json['message'] is List) {
      for (var item in json['message']) {
        if (item is String) {
          messages.add(item);
        } else if (item is Map && item['message'] != null) {
          messages.add(item['message'].toString());
        }
      }
    } else if (json['message'] is String) {
      messages.add(json['message']);
    }
    if (messages.isNotEmpty) {
      finalMessage = messages.join(' - ');
    }

    dynamic data = json['data'];

    return ResponseModel(
      success: json['success'] == true,
      message: finalMessage,
      messageList: messages,
      data: data,
    );
  }
}