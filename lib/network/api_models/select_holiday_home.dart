class SelectHolidayHomeResponse {
  bool? success;
  List<SelectHolidayHomeData>? data;

  SelectHolidayHomeResponse({this.success, this.data});

  SelectHolidayHomeResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <SelectHolidayHomeData>[];
      json['data'].forEach((v) {
        data!.add(SelectHolidayHomeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> mapData = <String, dynamic>{};
    mapData['success'] = success;
    if (data != null) {
      mapData['data'] = data!.map((v) => v.toJson()).toList();
    }
    return mapData;
  }
}

class SelectHolidayHomeData {
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
  String? hdHomeSuiteInsDate;

  SelectHolidayHomeData({
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

  SelectHolidayHomeData.fromJson(Map<String, dynamic> json) {
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