import './booking.dart';

class FilteredBookingsResponse {
  final bool success;
  final FilteredBookings data;

  FilteredBookingsResponse({
    required this.success,
    required this.data,
  });

  factory FilteredBookingsResponse.fromJson(Map<String, dynamic> json) {
    return FilteredBookingsResponse(
      success: json['success'] ?? false,
      data: FilteredBookings.fromJson(json['data'] ?? {}),
    );
  }
}

class FilteredBookings {
  final List<Booking> data;

  FilteredBookings({
    required this.data,
  });

  factory FilteredBookings.fromJson(Map<String, dynamic> json) {
    return FilteredBookings(
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Booking.fromJson(e))
          .toList(),
    );
  }
}
