class HdmbookingcheckavailResponse {
  bool? success;
  HdmbookingcheckavailDataWrapper? data;

  HdmbookingcheckavailResponse({this.success, this.data});

  HdmbookingcheckavailResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? HdmbookingcheckavailDataWrapper.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class HdmbookingcheckavailDataWrapper {
  List<HdmbookingcheckavailItem>? data;

  HdmbookingcheckavailDataWrapper({this.data});

  HdmbookingcheckavailDataWrapper.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <HdmbookingcheckavailItem>[];
      json['data'].forEach((v) {
        data!.add(HdmbookingcheckavailItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class HdmbookingcheckavailItem {
  int? hdHmTransSno;
  int? hdHomeBookingStatusCd;
  int? hdHomeBookingCurrwaiting;
  String? hdHomeBookingFromdt;
  String? hdHomeBookingTodt;
  String? daterange;

  HdmbookingcheckavailItem({
    this.hdHmTransSno,
    this.hdHomeBookingStatusCd,
    this.hdHomeBookingCurrwaiting,
    this.hdHomeBookingFromdt,
    this.hdHomeBookingTodt,
    this.daterange,
  });

  HdmbookingcheckavailItem.fromJson(Map<String, dynamic> json) {
    hdHmTransSno = json['hd_hm_trans_sno'];
    hdHomeBookingStatusCd = json['hd_home_booking_status_cd'];
    hdHomeBookingCurrwaiting = json['hd_home_booking_currwaiting'];
    hdHomeBookingFromdt = json['hd_home_booking_fromdt'];
    hdHomeBookingTodt = json['hd_home_booking_todt'];
    daterange = json['daterange'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hd_hm_trans_sno'] = hdHmTransSno;
    data['hd_home_booking_status_cd'] = hdHomeBookingStatusCd;
    data['hd_home_booking_currwaiting'] = hdHomeBookingCurrwaiting;
    data['hd_home_booking_fromdt'] = hdHomeBookingFromdt;
    data['hd_home_booking_todt'] = hdHomeBookingTodt;
    data['daterange'] = daterange;
    return data;
  }
}