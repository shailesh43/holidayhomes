class GenericResponse {
  final bool success;
  final ResponseData? data;

  GenericResponse({
    required this.success,
    this.data,
  });

  factory GenericResponse.fromJson(Map<String, dynamic> json) {
    return GenericResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? ResponseData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      // The ?. operator handles the null check automatically
      'data': data?.toJson(),
    };
  }
}

class ResponseData {
  // Changed from 'Null' to 'dynamic' to prevent parsing crashes
  // if the backend ever sends real data in this field later.
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