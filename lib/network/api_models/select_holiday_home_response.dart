class SelectHolidayHomeResponse {
  final bool? success;
  final List<HolidayHomeData>? data;

  SelectHolidayHomeResponse({this.success, this.data});

  factory SelectHolidayHomeResponse.fromJson(Map<String, dynamic> json) {
    return SelectHolidayHomeResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List?)
          ?.map((v) => HolidayHomeData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class HolidayHomeData {
  final int? hdHomeCd;
  final String? hdHomeName;
  final String? hdHomeLocName;
  final int? hdHomeLocCd;
  final String? hdHomeEligibility;
  final List<String>? hdHomeElig;

  HolidayHomeData({
    this.hdHomeCd,
    this.hdHomeName,
    this.hdHomeLocName,
    this.hdHomeLocCd,
    this.hdHomeEligibility,
    this.hdHomeElig,
  });

  factory HolidayHomeData.fromJson(Map<String, dynamic> json) {
    return HolidayHomeData(
      hdHomeCd: json['hd_home_cd'] as int?,
      hdHomeName: json['hd_home_name'] as String?,
      hdHomeLocName: json['hd_home_loc_name'] as String?,
      hdHomeLocCd: json['hd_home_loc_cd'] as int?,
      hdHomeEligibility: json['hd_home_eligibility'] as String?,
      hdHomeElig: (json['hd_home_elig'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hd_home_cd': hdHomeCd,
      'hd_home_name': hdHomeName,
      'hd_home_loc_name': hdHomeLocName,
      'hd_home_loc_cd': hdHomeLocCd,
      'hd_home_eligibility': hdHomeEligibility,
      'hd_home_elig': hdHomeElig,
    };
  }
}