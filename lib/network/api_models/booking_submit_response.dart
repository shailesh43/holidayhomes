class BookingSubmitResponse {
  final bool success;
  final String msg;
  final int bookingId;
  final BookingData? data;

  BookingSubmitResponse({
    required this.success,
    required this.msg,
    required this.bookingId,
    this.data,
  });

  factory BookingSubmitResponse.fromJson(Map<String, dynamic> json) {
    return BookingSubmitResponse(
      success: json['success'] ?? false,
      msg: json['msg']?.toString() ?? '',
      bookingId: _toInt(json['Bookingid']),
      // 🛠️ THE FIX: Checks if 'data' is actually a JSON Object (Map) before trying to read it.
      // If the server sends a boolean (like false), it safely assigns null instead of crashing!
      data: (json['data'] is Map<String, dynamic>)
          ? BookingData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'msg': msg,
      'Bookingid': bookingId,
      'data': data?.toJson(),
    };
  }

  // 🛡️ Helper to safely parse integers
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}

class BookingData {
  final int bookingId;
  final int bookingStatus;
  final String waitlistNumber;

  BookingData({
    required this.bookingId,
    required this.bookingStatus,
    required this.waitlistNumber,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingId: _toInt(json['bookingId']),
      bookingStatus: _toInt(json['bookingStatus']),
      waitlistNumber: json['waitlistNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'bookingStatus': bookingStatus,
      'waitlistNumber': waitlistNumber,
    };
  }

  // 🛡️ Helper to safely parse integers
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}