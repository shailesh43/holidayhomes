class KeyValueResponse {
  final bool success;
  final List<KeyValueData> data;

  KeyValueResponse({
    required this.success,
    this.data = const [],
  });

  factory KeyValueResponse.fromJson(Map<String, dynamic> json) {
    return KeyValueResponse(
      success: json['success'] ?? false,
      // Safely maps the list, or defaults to an empty list if null
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => KeyValueData.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class KeyValueData {
  // Using nullable or safe fallbacks to ensure backend mismatches don't crash the UI
  final String key;
  final int val;

  KeyValueData({
    required this.key,
    required this.val,
  });

  factory KeyValueData.fromJson(Map<String, dynamic> json) {
    return KeyValueData(
      key: json['key']?.toString() ?? '',
      // Safely parses integers even if the server accidentally sends a double or string
      val: _toInt(json['val']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'val': val,
    };
  }

  // Helper method to bulletproof integer parsing against unexpected backend types
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}