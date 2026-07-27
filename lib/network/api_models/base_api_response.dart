class BaseApiResponse {
  final bool success;
  final ResponseData? data;

  BaseApiResponse({
    required this.success,
    this.data,
  });

  factory BaseApiResponse.fromJson(Map<String, dynamic> json) {
    return BaseApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? ResponseData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class ResponseData {
  // Changed from 'Null' to 'dynamic' so the app won't crash
  // if the backend sends an actual message or ID later.
  final dynamic data;

  ResponseData({
    this.data,
  });

  factory ResponseData.fromJson(Map<String, dynamic> json) {
    return ResponseData(
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
    };
  }
}