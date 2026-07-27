class LocationResponse {
  bool? success;
  List<LocationData>? data;

  LocationResponse({this.success, this.data});

  LocationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <LocationData>[];
      json['data'].forEach((v) {
        data!.add(LocationData.fromJson(v));
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

class LocationData {
  int? key;
  String? val;

  LocationData({this.key, this.val});

  LocationData.fromJson(Map<String, dynamic> json) {
    // Aggressive parsing: Convert to int whether it comes in as an int or a String
    key = json['key'] is int ? json['key'] : int.tryParse(json['key']?.toString() ?? '');
    val = json['val']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['val'] = val;
    return data;
  }
}



