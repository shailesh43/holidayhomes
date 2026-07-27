class RelationResponse {
  final bool success;
  final List<RelationData> data;

  RelationResponse({
    required this.success,
    this.data = const [],
  });

  factory RelationResponse.fromJson(Map<String, dynamic> json) {
    return RelationResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => RelationData.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((v) => v.toJson()).toList(),
    };
  }
}

class RelationData {
  final int key;
  final String val;

  RelationData({
    required this.key,
    required this.val,
  });

  factory RelationData.fromJson(Map<String, dynamic> json) {
    return RelationData(
      key: _toInt(json['key']),
      val: json['val']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'val': val,
    };
  }

  // 🛡️ Helper to safely parse integers
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}