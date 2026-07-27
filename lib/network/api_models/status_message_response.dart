class StatusMessageResponse {
  final bool success;
  final String msg;

  StatusMessageResponse({
    required this.success,
    this.msg = '',
  });

  factory StatusMessageResponse.fromJson(Map<String, dynamic> json) {
    return StatusMessageResponse(
      success: json['success'] ?? false,
      // Safely parses the message, defaulting to an empty string if null
      msg: json['msg']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'msg': msg,
    };
  }
}