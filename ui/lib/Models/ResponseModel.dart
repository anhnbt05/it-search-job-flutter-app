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

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    dynamic rawMessage = json['message'];
    String finalMessage = 'Lỗi không xác định';
    List<String> messages = [];

    if (rawMessage is List) {
      messages = rawMessage
          .whereType<Map>()
          .map((item) => item['message']?.toString() ?? '')
          .where((msg) => msg.isNotEmpty)
          .toList();

      if (messages.isNotEmpty) {
        finalMessage = messages.join(' - ');
      }
    } else if (rawMessage is String) {
      finalMessage = rawMessage;
      messages.add(finalMessage);
    }

    return ResponseModel(
      success: json['success'] == true,
      message: finalMessage,
      messageList: messages,
      data: json['data'],
    );
  }
}
