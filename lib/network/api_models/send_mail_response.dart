class SendMailResponse {
  final bool success;
  final bool data;

  SendMailResponse({
    required this.success,
    required this.data,
  });

  factory SendMailResponse.fromJson(Map<String, dynamic> json) {
    return SendMailResponse(
      // Safely falls back to false if the key is missing or null
      success: json['success'] ?? false,
      data: json['data'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
    };
  }
}