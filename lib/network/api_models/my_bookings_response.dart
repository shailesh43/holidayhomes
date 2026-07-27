class MyBookingsResponse {
  final bool success;
  // Changed from 'Null' to 'dynamic' so it safely accepts actual booking data
  final List<dynamic> data;

  MyBookingsResponse({
    required this.success,
    this.data = const [],
  });

  factory MyBookingsResponse.fromJson(Map<String, dynamic> json) {
    return MyBookingsResponse(
      success: json['success'] ?? false,
      // Safely maps the list, or defaults to an empty list if null
      data: json['data'] != null ? List<dynamic>.from(json['data']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
    };
  }
}