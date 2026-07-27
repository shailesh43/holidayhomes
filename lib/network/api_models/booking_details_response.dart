class BookingDetailsResponse {
  bool? success;
  List<BookingData>? data;

  BookingDetailsResponse({this.success, this.data});

  BookingDetailsResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <BookingData>[];
      json['data'].forEach((v) {
        data!.add(BookingData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingData {
  int? hdHmTransSno;
  int? hdHomelocCd;
  String? hdLocName;
  int? hdHomeCd;
  String? hdHomeName;
  int? hdHomeSuiteCd;
  String? hdHomeSuiteName;
  String? hdHomeSuiteCatg;
  int? hdHomeBookingEmpno;
  String? hdHomeBookingEmpname;
  String? hdHomeBookingEmpemail;
  String? hdHomeBookingEmpmob;
  String? hdHomeBookingEmpdept;
  String? hdHomeBookingEmpdesig;
  String? hdHomeBookingEmpcostcent;
  String? hdHomeBookingFromdt;
  String? hdHomeBookingTodt;
  dynamic hdHomeBookingIscancel;
  dynamic hdHomeBookingCanceldt;
  dynamic hdHomeBookingCancelBY;
  dynamic hdHomeBookingCancelremark;
  int? hdHomeBookingWaiting;
  int? hdHomeBookingCurrwaiting;
  String? hdHomeBookingBY;
  dynamic hdHomeBookingRating;
  dynamic hdHomeBookingFeedback;
  dynamic hdHomeBookingStatus;
  int? hdHomeBookByEmpno;
  String? hdHomeBookByEmpName;
  String? hdHomeBookByEmail;
  String? hdHomeBookingActive;
  String? hdHomeBookingInsBy;
  String? hdHomeBookingInsDate;
  int? hdHomeBookingStatusCd;
  String? bookingStatus;
  dynamic hdHomeCheckin;
  dynamic hdHomeCheckindt;
  dynamic hdHomeCheckinby;
  String? hdHomeCaretakername;
  String? hdHomeCaretakerEmail;
  String? hdHomeCaretakerMobile;

  BookingData({
    this.hdHmTransSno, this.hdHomelocCd, this.hdLocName, this.hdHomeCd, this.hdHomeName,
    this.hdHomeSuiteCd, this.hdHomeSuiteName, this.hdHomeSuiteCatg, this.hdHomeBookingEmpno,
    this.hdHomeBookingEmpname, this.hdHomeBookingEmpemail, this.hdHomeBookingEmpmob,
    this.hdHomeBookingEmpdept, this.hdHomeBookingEmpdesig, this.hdHomeBookingEmpcostcent,
    this.hdHomeBookingFromdt, this.hdHomeBookingTodt, this.hdHomeBookingIscancel,
    this.hdHomeBookingCanceldt, this.hdHomeBookingCancelBY, this.hdHomeBookingCancelremark,
    this.hdHomeBookingWaiting, this.hdHomeBookingCurrwaiting, this.hdHomeBookingBY,
    this.hdHomeBookingRating, this.hdHomeBookingFeedback, this.hdHomeBookingStatus,
    this.hdHomeBookByEmpno, this.hdHomeBookByEmpName, this.hdHomeBookByEmail,
    this.hdHomeBookingActive, this.hdHomeBookingInsBy, this.hdHomeBookingInsDate,
    this.hdHomeBookingStatusCd, this.bookingStatus, this.hdHomeCheckin, this.hdHomeCheckindt,
    this.hdHomeCheckinby, this.hdHomeCaretakername, this.hdHomeCaretakerEmail, this.hdHomeCaretakerMobile,
  });

  BookingData.fromJson(Map<String, dynamic> json) {
    hdHmTransSno = json['hd_hm_trans_sno'];
    hdHomelocCd = json['hd_homeloc_cd'];
    hdLocName = json['hd_loc_name'];
    hdHomeCd = json['hd_home_cd'];
    hdHomeName = json['hd_home_name'];
    hdHomeSuiteCd = json['hd_home_suite_cd'];
    hdHomeSuiteName = json['hd_home_suite_name'];
    hdHomeSuiteCatg = json['hd_home_suite_catg'];
    hdHomeBookingEmpno = json['hd_home_booking_empno'];
    hdHomeBookingEmpname = json['hd_home_booking_empname'];
    hdHomeBookingEmpemail = json['hd_home_booking_empemail'];
    hdHomeBookingEmpmob = json['hd_home_booking_empmob'];
    hdHomeBookingEmpdept = json['hd_home_booking_empdept'];
    hdHomeBookingEmpdesig = json['hd_home_booking_empdesig'];
    hdHomeBookingEmpcostcent = json['hd_home_booking_empcostcent'];
    hdHomeBookingFromdt = json['hd_home_booking_fromdt'];
    hdHomeBookingTodt = json['hd_home_booking_todt'];
    hdHomeBookingIscancel = json['hd_home_booking_iscancel'];
    hdHomeBookingCanceldt = json['hd_home_booking_canceldt'];
    hdHomeBookingCancelBY = json['hd_home_booking_cancel_b_y'];
    hdHomeBookingCancelremark = json['hd_home_booking_cancelremark'];
    hdHomeBookingWaiting = json['hd_home_booking_waiting'];
    hdHomeBookingCurrwaiting = json['hd_home_booking_currwaiting'];
    hdHomeBookingBY = json['hd_home_booking_b_y'];
    hdHomeBookingRating = json['hd_home_booking_rating'];
    hdHomeBookingFeedback = json['hd_home_booking_feedback'];
    hdHomeBookingStatus = json['hd_home_booking_status'];
    hdHomeBookByEmpno = json['hd_home_book_by_empno'];
    hdHomeBookByEmpName = json['hd_home_book_by_emp_name'];
    hdHomeBookByEmail = json['hd_home_book_by_email'];
    hdHomeBookingActive = json['hd_home_booking_active'];
    hdHomeBookingInsBy = json['hd_home_booking_ins_by'];
    hdHomeBookingInsDate = json['hd_home_booking_ins_date'];
    hdHomeBookingStatusCd = json['hd_home_booking_status_cd'];
    bookingStatus = json['booking_status'];
    hdHomeCheckin = json['hd_home_checkin'];
    hdHomeCheckindt = json['hd_home_checkindt'];
    hdHomeCheckinby = json['hd_home_checkinby'];
    hdHomeCaretakername = json['hd_home_caretakername'];
    hdHomeCaretakerEmail = json['hd_home_caretaker_email'];
    hdHomeCaretakerMobile = json['hd_home_caretaker_mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // Mapping removed for brevity here, but keep your original toJson logic if you need it!
    return data;
  }
}