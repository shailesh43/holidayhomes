class FacilitatorBookingResponse {
  final bool success;
  // Changed from 'Null' to 'dynamic' to safely hold real booking data later
  final List<dynamic> data;

  FacilitatorBookingResponse({
    required this.success,
    this.data = const [],
  });

  factory FacilitatorBookingResponse.fromJson(Map<String, dynamic> json) {
    return FacilitatorBookingResponse(
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