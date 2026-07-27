class BookingResultResponse {
  final bool success;
  final BookingResultData? data;

  BookingResultResponse({
    required this.success,
    this.data,
  });

  factory BookingResultResponse.fromJson(Map<String, dynamic> json) {
    return BookingResultResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? BookingResultData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      // The ?. operator safely handles the null check for you
      'data': data?.toJson(),
    };
  }
}

class BookingResultData {
  final String bookingId;
  final bool success;

  BookingResultData({
    this.bookingId = '',
    required this.success,
  });

  factory BookingResultData.fromJson(Map<String, dynamic> json) {
    return BookingResultData(
      // Safely parses the booking ID, defaulting to an empty string if null
      bookingId: json['bookingId']?.toString() ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'success': success,
    };
  }
}