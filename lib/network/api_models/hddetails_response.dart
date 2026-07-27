class HdDetailsResponse {
  bool? success;
  List<HdDetailsData>? data;

  HdDetailsResponse({this.success, this.data});

  factory HdDetailsResponse.fromJson(Map<String, dynamic> json) {
    return HdDetailsResponse(
      success: json['success'] as bool?,
      data: (json['data'] as List?)
          ?.map((v) => HdDetailsData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data!.map((v) => v.toJson()).toList(),
    };
  }
}

class HdDetailsData {
  int? hdHomeCd;
  String? hdHomeName;
  int? hdHomeLocCd;
  String? hdHomeLocName;
  String? hdHomeAddress1;
  String? hdHomeAddress2;
  String? hdHomeAddress3;
  int? hdHomePin;
  int? hdHomeCat;
  String? hdHomePhone;
  String? hdhomeContactPersonName;
  String? hdhomeContactPersonMobile;
  String? hdhomeContactPersonEmail;
  int? hdhomeAdvanceDays;
  String? hdHomeEligibility;
  String? hdLocActive;
  String? hdLocInsBy;
  String? hdLocInsDate;
  List<String>? hdHomeElig;
  double? hdHomeLat;
  double? hdHomeLong;
  String? hdThingsToDo1;
  String? hdThingsToDo2;
  String? hdThingsToDo3;
  String? hdThingsToDo4;
  String? hdThingsToDo5;
  String? hdHomeThingsToDoImage1;
  String? hdHomeThingsToDoImage2;
  String? hdHomeThingsToDoImage3;
  String? hdHomeThingsToDoImage4;
  String? hdHomeThingsToDoImage5;
  String? hdHomeThingsToDoHeader1;
  String? hdHomeThingsToDoHeader2;
  String? hdHomeThingsToDoHeader3;
  String? hdHomeThingsToDoHeader4;
  String? hdHomeThingsToDoHeader5;
  String? hdHomeImage;
  String? hdHomeCarouselmage1;
  String? hdHomeCarouselmage2;
  String? hdHomeCarouselmage3;
  String? hdHomeSwimmingpool;
  String? hdHomeStartdate;
  String? hdHomeEnddate;

  HdDetailsData({
    this.hdHomeCd,
    this.hdHomeName,
    this.hdHomeLocCd,
    this.hdHomeLocName,
    this.hdHomeAddress1,
    this.hdHomeAddress2,
    this.hdHomeAddress3,
    this.hdHomePin,
    this.hdHomeCat,
    this.hdHomePhone,
    this.hdhomeContactPersonName,
    this.hdhomeContactPersonMobile,
    this.hdhomeContactPersonEmail,
    this.hdhomeAdvanceDays,
    this.hdHomeEligibility,
    this.hdLocActive,
    this.hdLocInsBy,
    this.hdLocInsDate,
    this.hdHomeElig,
    this.hdHomeLat,
    this.hdHomeLong,
    this.hdThingsToDo1,
    this.hdThingsToDo2,
    this.hdThingsToDo3,
    this.hdThingsToDo4,
    this.hdThingsToDo5,
    this.hdHomeThingsToDoImage1,
    this.hdHomeThingsToDoImage2,
    this.hdHomeThingsToDoImage3,
    this.hdHomeThingsToDoImage4,
    this.hdHomeThingsToDoImage5,
    this.hdHomeThingsToDoHeader1,
    this.hdHomeThingsToDoHeader2,
    this.hdHomeThingsToDoHeader3,
    this.hdHomeThingsToDoHeader4,
    this.hdHomeThingsToDoHeader5,
    this.hdHomeImage,
    this.hdHomeCarouselmage1,
    this.hdHomeCarouselmage2,
    this.hdHomeCarouselmage3,
    this.hdHomeSwimmingpool,
    this.hdHomeStartdate,
    this.hdHomeEnddate,
  });

  factory HdDetailsData.fromJson(Map<String, dynamic> json) {
    return HdDetailsData(
      hdHomeCd: json['hdHomeCd'] as int?,
      hdHomeName: json['hdHomeName']?.toString(),
      hdHomeLocCd: json['hdHomeLocCd'] as int?,
      hdHomeLocName: json['hdHomeLocName']?.toString(),
      hdHomeAddress1: json['hdHomeAddress1']?.toString(),
      hdHomeAddress2: json['hdHomeAddress2']?.toString(),
      hdHomeAddress3: json['hdHomeAddress3']?.toString(),
      hdHomePin: json['hdHomePin'] as int?,
      hdHomeCat: json['hdHomeCat'] as int?,
      hdHomePhone: json['hdHomePhone']?.toString(),
      hdhomeContactPersonName: json['hdhomeContactPersonName']?.toString(),
      hdhomeContactPersonMobile: json['hdhomeContactPersonMobile']?.toString(),
      hdhomeContactPersonEmail: json['hdhomeContactPersonEmail']?.toString(),
      hdhomeAdvanceDays: json['hdhomeAdvanceDays'] as int?,
      hdHomeEligibility: json['hdHomeEligibility']?.toString(),
      hdLocActive: json['hdLocActive']?.toString(),
      hdLocInsBy: json['hdLocInsBy']?.toString(),
      hdLocInsDate: json['hdLocInsDate']?.toString(),
      hdHomeElig: (json['hd_home_elig'] as List?)?.map((e) => e.toString()).toList(),
      hdHomeLat: (json['hdHomeLat'] as num?)?.toDouble(),
      hdHomeLong: (json['hdHomeLong'] as num?)?.toDouble(),
      hdThingsToDo1: json['hdThingsToDo_1']?.toString(),
      hdThingsToDo2: json['hdThingsToDo_2']?.toString(),
      hdThingsToDo3: json['hdThingsToDo_3']?.toString(),
      hdThingsToDo4: json['hdThingsToDo_4']?.toString(),
      hdThingsToDo5: json['hdThingsToDo_5']?.toString(),
      hdHomeThingsToDoImage1: json['hdHomeThingsToDoImage1']?.toString(),
      hdHomeThingsToDoImage2: json['hdHomeThingsToDoImage2']?.toString(),
      hdHomeThingsToDoImage3: json['hdHomeThingsToDoImage3']?.toString(),
      hdHomeThingsToDoImage4: json['hdHomeThingsToDoImage4']?.toString(),
      hdHomeThingsToDoImage5: json['hdHomeThingsToDoImage5']?.toString(),
      hdHomeThingsToDoHeader1: json['hdHomeThingsToDoHeader1']?.toString(),
      hdHomeThingsToDoHeader2: json['hdHomeThingsToDoHeader2']?.toString(),
      hdHomeThingsToDoHeader3: json['hdHomeThingsToDoHeader3']?.toString(),
      hdHomeThingsToDoHeader4: json['hdHomeThingsToDoHeader4']?.toString(),
      hdHomeThingsToDoHeader5: json['hdHomeThingsToDoHeader5']?.toString(),
      hdHomeImage: json['hdHomeImage']?.toString(),
      hdHomeCarouselmage1: json['hdHomeCarouselmage1']?.toString(),
      hdHomeCarouselmage2: json['hdHomeCarouselmage2']?.toString(),
      hdHomeCarouselmage3: json['hdHomeCarouselmage3']?.toString(),
      hdHomeSwimmingpool: json['hdHomeSwimmingpool']?.toString(),
      hdHomeStartdate: json['hdHomeStartdate']?.toString(),
      hdHomeEnddate: json['hdHomeEnddate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hdHomeCd': hdHomeCd,
      'hdHomeName': hdHomeName,
      'hdHomeLocCd': hdHomeLocCd,
      'hdHomeLocName': hdHomeLocName,
      'hdHomeAddress1': hdHomeAddress1,
      'hdHomeAddress2': hdHomeAddress2,
      'hdHomeAddress3': hdHomeAddress3,
      'hdHomePin': hdHomePin,
      'hdHomeCat': hdHomeCat,
      'hdHomePhone': hdHomePhone,
      'hdhomeContactPersonName': hdhomeContactPersonName,
      'hdhomeContactPersonMobile': hdhomeContactPersonMobile,
      'hdhomeContactPersonEmail': hdhomeContactPersonEmail,
      'hdhomeAdvanceDays': hdhomeAdvanceDays,
      'hdHomeEligibility': hdHomeEligibility,
      'hdLocActive': hdLocActive,
      'hdLocInsBy': hdLocInsBy,
      'hdLocInsDate': hdLocInsDate,
      'hd_home_elig': hdHomeElig,
      'hdHomeLat': hdHomeLat,
      'hdHomeLong': hdHomeLong,
      'hdThingsToDo_1': hdThingsToDo1,
      'hdThingsToDo_2': hdThingsToDo2,
      'hdThingsToDo_3': hdThingsToDo3,
      'hdThingsToDo_4': hdThingsToDo4,
      'hdThingsToDo_5': hdThingsToDo5,
      'hdHomeThingsToDoImage1': hdHomeThingsToDoImage1,
      'hdHomeThingsToDoImage2': hdHomeThingsToDoImage2,
      'hdHomeThingsToDoImage3': hdHomeThingsToDoImage3,
      'hdHomeThingsToDoImage4': hdHomeThingsToDoImage4,
      'hdHomeThingsToDoImage5': hdHomeThingsToDoImage5,
      'hdHomeThingsToDoHeader1': hdHomeThingsToDoHeader1,
      'hdHomeThingsToDoHeader2': hdHomeThingsToDoHeader2,
      'hdHomeThingsToDoHeader3': hdHomeThingsToDoHeader3,
      'hdHomeThingsToDoHeader4': hdHomeThingsToDoHeader4,
      'hdHomeThingsToDoHeader5': hdHomeThingsToDoHeader5,
      'hdHomeImage': hdHomeImage,
      'hdHomeCarouselmage1': hdHomeCarouselmage1,
      'hdHomeCarouselmage2': hdHomeCarouselmage2,
      'hdHomeCarouselmage3': hdHomeCarouselmage3,
      'hdHomeSwimmingpool': hdHomeSwimmingpool,
      'hdHomeStartdate': hdHomeStartdate,
      'hdHomeEnddate': hdHomeEnddate,
    };
  }
}