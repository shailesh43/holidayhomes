class PostResponse {
  final bool success;
  final List<PostData> data;

  PostResponse({
    required this.success,
    this.data = const [],
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PostData.fromJson(e))
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

class PostData {
  final String key;
  final int val;

  PostData({
    required this.key,
    required this.val,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      key: json['key']?.toString() ?? '',
      val: _toInt(json['val']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'val': val,
    };
  }

  // 🛡️ Helper to safely parse integers, preventing crashes if the server sends a String
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}