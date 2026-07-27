class SuiteResponse {
  bool? success;
  List<SuiteData>? data;

  SuiteResponse({this.success, this.data});

  SuiteResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SuiteData>[];
      json['data'].forEach((v) {
        data!.add(SuiteData.fromJson(v));
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

class SuiteData {
  int? hdHomeCd;
  String? hdHomeName;
  int? hdHomeSuiteCd;
  String? hdHomeSuiteName;
  String? hdHomeSuiteCatg;
  int? hdHomeSuiteMaxdays;
  int? hdHomeSuiteMaxcap;
  String? hdHomeSuiteNoofbathroom;
  String? hdHomeMaxdayallow;
  String? hdHomeSuiteActive;
  String? hdHomeSuiteInsBy;

  // 🛠️ FIXED: Changed from explicitly 'Null' to 'dynamic' to prevent future crashes
  dynamic hdHomeSuiteInsDate;

  SuiteData({
    this.hdHomeCd,
    this.hdHomeName,
    this.hdHomeSuiteCd,
    this.hdHomeSuiteName,
    this.hdHomeSuiteCatg,
    this.hdHomeSuiteMaxdays,
    this.hdHomeSuiteMaxcap,
    this.hdHomeSuiteNoofbathroom,
    this.hdHomeMaxdayallow,
    this.hdHomeSuiteActive,
    this.hdHomeSuiteInsBy,
    this.hdHomeSuiteInsDate,
  });

  SuiteData.fromJson(Map<String, dynamic> json) {
    hdHomeCd = json['hdHomeCd'];
    hdHomeName = json['hdHomeName'];
    hdHomeSuiteCd = json['hdHomeSuiteCd'];
    hdHomeSuiteName = json['hdHomeSuiteName'];
    hdHomeSuiteCatg = json['hdHomeSuiteCatg'];
    hdHomeSuiteMaxdays = json['hdHomeSuiteMaxdays'];
    hdHomeSuiteMaxcap = json['hdHomeSuiteMaxcap'];
    hdHomeSuiteNoofbathroom = json['hdHomeSuiteNoofbathroom'];
    hdHomeMaxdayallow = json['hdHomeMaxdayallow'];
    hdHomeSuiteActive = json['hdHomeSuiteActive'];
    hdHomeSuiteInsBy = json['hdHomeSuiteInsBy'];
    hdHomeSuiteInsDate = json['hdHomeSuiteInsDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hdHomeCd'] = hdHomeCd;
    data['hdHomeName'] = hdHomeName;
    data['hdHomeSuiteCd'] = hdHomeSuiteCd;
    data['hdHomeSuiteName'] = hdHomeSuiteName;
    data['hdHomeSuiteCatg'] = hdHomeSuiteCatg;
    data['hdHomeSuiteMaxdays'] = hdHomeSuiteMaxdays;
    data['hdHomeSuiteMaxcap'] = hdHomeSuiteMaxcap;
    data['hdHomeSuiteNoofbathroom'] = hdHomeSuiteNoofbathroom;
    data['hdHomeMaxdayallow'] = hdHomeMaxdayallow;
    data['hdHomeSuiteActive'] = hdHomeSuiteActive;
    data['hdHomeSuiteInsBy'] = hdHomeSuiteInsBy;
    data['hdHomeSuiteInsDate'] = hdHomeSuiteInsDate;
    return data;
  }
}