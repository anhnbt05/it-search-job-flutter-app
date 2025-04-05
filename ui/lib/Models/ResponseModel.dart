class ResponseModel {
  final bool success;
  final String message;

  ResponseModel({required this.success, required this.message});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      success: json['success'],
      message: json['message'],
    );
  }
}
