class HdhmbookingdetailsNext30daysResponse {
  bool? success;
  HdhmbookingdetailsNext30daysDataWrapper? data;

  HdhmbookingdetailsNext30daysResponse({this.success, this.data});

  HdhmbookingdetailsNext30daysResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? HdhmbookingdetailsNext30daysDataWrapper.fromJson(json['data']) : null;
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

class HdhmbookingdetailsNext30daysDataWrapper {
  List<HdhmbookingdetailsNext30daysItem>? data;

  HdhmbookingdetailsNext30daysDataWrapper({this.data});

  HdhmbookingdetailsNext30daysDataWrapper.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <HdhmbookingdetailsNext30daysItem>[];
      json['data'].forEach((v) {
        data!.add(HdhmbookingdetailsNext30daysItem.fromJson(v));
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

class HdhmbookingdetailsNext30daysItem {
  int? hdHmTransSno;
  int? hdHomeBookingEmpno;
  String? hdHomeBookingEmpname;
  int? hdHomeBookingStatusCd;
  String? bookingStatus;
  int? hdHomeBookingWaiting;
  int? hdHomeBookingCurrwaiting;
  int? hdHomeWaitlistCategory;
  String? hdHomeBookingFromdt;
  String? hdHomeBookingTodt;
  String? currentWaitingno;
  String? daterange;

  HdhmbookingdetailsNext30daysItem({
    this.hdHmTransSno,
    this.hdHomeBookingEmpno,
    this.hdHomeBookingEmpname,
    this.hdHomeBookingStatusCd,
    this.bookingStatus,
    this.hdHomeBookingWaiting,
    this.hdHomeBookingCurrwaiting,
    this.hdHomeWaitlistCategory,
    this.hdHomeBookingFromdt,
    this.hdHomeBookingTodt,
    this.currentWaitingno,
    this.daterange,
  });

  HdhmbookingdetailsNext30daysItem.fromJson(Map<String, dynamic> json) {
    hdHmTransSno = json['hd_hm_trans_sno'];
    hdHomeBookingEmpno = json['hd_home_booking_empno'];
    hdHomeBookingEmpname = json['hd_home_booking_empname'];
    hdHomeBookingStatusCd = json['hd_home_booking_status_cd'];
    bookingStatus = json['booking_status'];
    hdHomeBookingWaiting = json['hd_home_booking_waiting'];
    hdHomeBookingCurrwaiting = json['hd_home_booking_currwaiting'];
    hdHomeWaitlistCategory = json['hd_home_waitlist_category'];
    hdHomeBookingFromdt = json['hd_home_booking_fromdt'];
    hdHomeBookingTodt = json['hd_home_booking_todt'];
    currentWaitingno = json['current_waitingno'];
    daterange = json['daterange'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hd_hm_trans_sno'] = hdHmTransSno;
    data['hd_home_booking_empno'] = hdHomeBookingEmpno;
    data['hd_home_booking_empname'] = hdHomeBookingEmpname;
    data['hd_home_booking_status_cd'] = hdHomeBookingStatusCd;
    data['booking_status'] = bookingStatus;
    data['hd_home_booking_waiting'] = hdHomeBookingWaiting;
    data['hd_home_booking_currwaiting'] = hdHomeBookingCurrwaiting;
    data['hd_home_waitlist_category'] = hdHomeWaitlistCategory;
    data['hd_home_booking_fromdt'] = hdHomeBookingFromdt;
    data['hd_home_booking_todt'] = hdHomeBookingTodt;
    data['current_waitingno'] = currentWaitingno;
    data['daterange'] = daterange;
    return data;
  }
}