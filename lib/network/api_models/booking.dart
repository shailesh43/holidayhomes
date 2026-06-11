class Booking {
  final int hdHmTransSno;
  final int hdHomelocCd;
  final String hdLocName;
  final int hdHomeCd;
  final String hdHomeName;
  final int hdHomeSuiteCd;
  final String hdHomeSuiteName;
  final String hdHomeSuiteCatg;

  final int hdHomeBookingEmpno;
  final String hdHomeBookingEmpname;
  final String hdHomeBookingEmpemail;
  final String hdHomeBookingEmpmob;
  final String hdHomeBookingEmpdept;
  final String hdHomeBookingEmpdesig;
  final String hdHomeBookingEmpcostcent;

  final String hdHomeBookingFromdt;
  final String hdHomeBookingTodt;

  final dynamic hdHomeBookingIscancel;
  final dynamic hdHomeBookingCanceldt;
  final dynamic hdHomeBookingCancelBY;
  final dynamic hdHomeBookingCancelremark;

  final int hdHomeBookingWaiting;
  final int hdHomeBookingCurrwaiting;

  final String hdHomeBookingBY;

  final dynamic hdHomeBookingRating;
  final dynamic hdHomeBookingFeedback;
  final dynamic hdHomeBookingStatus;

  final int hdHomeBookByEmpno;
  final String hdHomeBookByEmpName;
  final String hdHomeBookByEmail;

  final String hdHomeBookingActive;
  final String hdHomeBookingInsBy;
  final String hdHomeBookingInsDate;

  final dynamic hdHomeCheckin;
  final dynamic hdHomeCheckindt;
  final dynamic hdHomeCheckinby;

  final int hdHomeBookingStatusCd;
  final String bookingStatus;

  final String hdHomeCaretakername;
  final String hdHomeCaretakerEmail;
  final int hdHomeCaretakerMobile;

  Booking({
    required this.hdHmTransSno,
    required this.hdHomelocCd,
    required this.hdLocName,
    required this.hdHomeCd,
    required this.hdHomeName,
    required this.hdHomeSuiteCd,
    required this.hdHomeSuiteName,
    required this.hdHomeSuiteCatg,
    required this.hdHomeBookingEmpno,
    required this.hdHomeBookingEmpname,
    required this.hdHomeBookingEmpemail,
    required this.hdHomeBookingEmpmob,
    required this.hdHomeBookingEmpdept,
    required this.hdHomeBookingEmpdesig,
    required this.hdHomeBookingEmpcostcent,
    required this.hdHomeBookingFromdt,
    required this.hdHomeBookingTodt,
    this.hdHomeBookingIscancel,
    this.hdHomeBookingCanceldt,
    this.hdHomeBookingCancelBY,
    this.hdHomeBookingCancelremark,
    required this.hdHomeBookingWaiting,
    required this.hdHomeBookingCurrwaiting,
    required this.hdHomeBookingBY,
    this.hdHomeBookingRating,
    this.hdHomeBookingFeedback,
    this.hdHomeBookingStatus,
    required this.hdHomeBookByEmpno,
    required this.hdHomeBookByEmpName,
    required this.hdHomeBookByEmail,
    required this.hdHomeBookingActive,
    required this.hdHomeBookingInsBy,
    required this.hdHomeBookingInsDate,
    this.hdHomeCheckin,
    this.hdHomeCheckindt,
    this.hdHomeCheckinby,
    required this.hdHomeBookingStatusCd,
    required this.bookingStatus,
    required this.hdHomeCaretakername,
    required this.hdHomeCaretakerEmail,
    required this.hdHomeCaretakerMobile,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      hdHmTransSno: json['hd_hm_trans_sno'] ?? 0,
      hdHomelocCd: json['hd_homeloc_cd'] ?? 0,
      hdLocName: json['hd_loc_name'] ?? '',
      hdHomeCd: json['hd_home_cd'] ?? 0,
      hdHomeName: json['hd_home_name'] ?? '',
      hdHomeSuiteCd: json['hd_home_suite_cd'] ?? 0,
      hdHomeSuiteName: json['hd_home_suite_name'] ?? '',
      hdHomeSuiteCatg: json['hd_home_suite_catg'] ?? '',
      hdHomeBookingEmpno: json['hd_home_booking_empno'] ?? 0,
      hdHomeBookingEmpname: json['hd_home_booking_empname'] ?? '',
      hdHomeBookingEmpemail: json['hd_home_booking_empemail'] ?? '',
      hdHomeBookingEmpmob: json['hd_home_booking_empmob'] ?? '',
      hdHomeBookingEmpdept: json['hd_home_booking_empdept'] ?? '',
      hdHomeBookingEmpdesig: json['hd_home_booking_empdesig'] ?? '',
      hdHomeBookingEmpcostcent: json['hd_home_booking_empcostcent'] ?? '',
      hdHomeBookingFromdt: json['hd_home_booking_fromdt'] ?? '',
      hdHomeBookingTodt: json['hd_home_booking_todt'] ?? '',
      hdHomeBookingIscancel: json['hd_home_booking_iscancel'],
      hdHomeBookingCanceldt: json['hd_home_booking_canceldt'],
      hdHomeBookingCancelBY: json['hd_home_booking_cancel_b_y'],
      hdHomeBookingCancelremark: json['hd_home_booking_cancelremark'],
      hdHomeBookingWaiting: json['hd_home_booking_waiting'] ?? 0,
      hdHomeBookingCurrwaiting:
      json['hd_home_booking_currwaiting'] ?? 0,
      hdHomeBookingBY: json['hd_home_booking_b_y'] ?? '',
      hdHomeBookingRating: json['hd_home_booking_rating'],
      hdHomeBookingFeedback: json['hd_home_booking_feedback'],
      hdHomeBookingStatus: json['hd_home_booking_status'],
      hdHomeBookByEmpno: json['hd_home_book_by_empno'] ?? 0,
      hdHomeBookByEmpName: json['hd_home_book_by_emp_name'] ?? '',
      hdHomeBookByEmail: json['hd_home_book_by_email'] ?? '',
      hdHomeBookingActive: json['hd_home_booking_active'] ?? '',
      hdHomeBookingInsBy: json['hd_home_booking_ins_by'] ?? '',
      hdHomeBookingInsDate: json['hd_home_booking_ins_date'] ?? '',
      hdHomeCheckin: json['hd_home_checkin'],
      hdHomeCheckindt: json['hd_home_checkindt'],
      hdHomeCheckinby: json['hd_home_checkinby'],
      hdHomeBookingStatusCd:
      json['hd_home_booking_status_cd'] ?? 0,
      bookingStatus: (json['booking_status'] ?? '').toString().trim(),
      hdHomeCaretakername: json['hd_home_caretakername'] ?? '',
      hdHomeCaretakerEmail:
      json['hd_home_caretaker_email'] ?? '',
      hdHomeCaretakerMobile:
      json['hd_home_caretaker_mobile'] ?? 0,
    );
  }
}