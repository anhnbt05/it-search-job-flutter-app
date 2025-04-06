class ResponseModel {
  final bool success;
  final String message;

  ResponseModel({
    required this.success,
    required this.message,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    dynamic rawMessage = json['message'];
    String finalMessage;

    if (rawMessage is List) {
      finalMessage = rawMessage.join(' - ');
    } else {
      finalMessage = rawMessage?.toString() ?? 'Lỗi không xác định';
    }

    return ResponseModel(
      success: json['success'] == true,
      message: finalMessage,
    );
  }
}
