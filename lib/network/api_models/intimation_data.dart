import './booking.dart';
import './guest_info_response.dart';

class IntimationData {
  final Booking booking;
  final List<GuestInfo> guests;
  IntimationData({required this.booking, required this.guests});

  factory IntimationData.fromJson(Map<String, dynamic> json) {
    return IntimationData(
      booking: Booking.fromJson(json['booking']),
      guests: (json['guests'] as List<dynamic>?)
          ?.map((e) => GuestInfo.fromJson(e))
          .toList() ??
          [],
    );
  }
}