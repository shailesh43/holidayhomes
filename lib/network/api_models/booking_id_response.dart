import './booking.dart';

class BookingIdResponse {
  final bool success;
  final List<Booking> data;

  BookingIdResponse({
    required this.success,
    required this.data,
  });

  factory BookingIdResponse.fromJson(Map<String, dynamic> json) {
    return BookingIdResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Booking.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
    };
  }
}