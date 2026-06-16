class GuestInfoResponse {
  final bool success;
  final List<GuestInfo> data;

  GuestInfoResponse({
    required this.success,
    required this.data,
  });

  factory GuestInfoResponse.fromJson(Map<String, dynamic> json) {
    return GuestInfoResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => GuestInfo.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class GuestInfo {
  final int hdHmTransSno;
  final String guestName;
  final int guestRelation;
  final String relName;
  final int guestAge;

  GuestInfo({
    required this.hdHmTransSno,
    required this.guestName,
    required this.guestRelation,
    required this.relName,
    required this.guestAge,
  });

  factory GuestInfo.fromJson(Map<String, dynamic> json) {
    return GuestInfo(
      hdHmTransSno: _toInt(json['hd_hm_trans_sno']),
      guestName: json['guest_name']?.toString() ?? '',
      guestRelation: _toInt(json['guest_relation']),
      relName: json['rel_name']?.toString() ?? '',
      guestAge: _toInt(json['guest_age']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}