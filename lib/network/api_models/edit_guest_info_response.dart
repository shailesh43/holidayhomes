class EditGuestInfoResponse {
  final bool success;
  final List<EditGuestData> data;

  EditGuestInfoResponse({
    required this.success,
    this.data = const [],
  });

  factory EditGuestInfoResponse.fromJson(Map<String, dynamic> json) {
    return EditGuestInfoResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? (json['data'] as List).map((v) => EditGuestData.fromJson(v)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((v) => v.toJson()).toList(),
    };
  }
}

class EditGuestData {
  final int? id;
  final int? hdHmTransSno;
  final String? guestName;
  final int? guestRelation;
  final int? guestAge;

  EditGuestData({
    this.id,
    this.hdHmTransSno,
    this.guestName,
    this.guestRelation,
    this.guestAge,
  });

  factory EditGuestData.fromJson(Map<String, dynamic> json) {
    return EditGuestData(
      id: json['id'],
      hdHmTransSno: json['hd_hm_trans_sno'],
      guestName: json['guest_name'],
      guestRelation: json['guest_relation'],
      guestAge: json['guest_age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hd_hm_trans_sno': hdHmTransSno,
      'guest_name': guestName,
      'guest_relation': guestRelation,
      'guest_age': guestAge,
    };
  }
}