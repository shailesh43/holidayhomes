import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

// REFERENCES
import '../../core/constants/api_constants.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';

class ApiClient {
  // Static pinned client — shared across ALL instances
  static http.Client? _pinnedClient;
  static bool _isPinningVerified = false; // static so all instances share it

  final Logger logger = Logger();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // Called ONCE from main() before app loads
  Future<void> initSSLPinning() async {
    if (_isPinningVerified) return; // already done, skip
    _pinnedClient = await _buildPinnedClient();
    _isPinningVerified = true;
    logger.d("SSL Pinning initialized");
  }

  // Builds the pinned HTTP client from your .pem cert
  static Future<http.Client> _buildPinnedClient() async {
    final sslCert = await rootBundle.load('assets/docs/bizapps-cert.pem');
    final securityContext = SecurityContext();
    securityContext.setTrustedCertificatesBytes(sslCert.buffer.asInt8List());

    final httpClient = HttpClient(context: securityContext);
    // httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
    //   return host == "bizapps.tatapower.com"; // only allow your domain
    // };

    return IOClient(httpClient);
  }

  static http.Client get pinnedHttpClient {
    if (!_isPinningVerified || _pinnedClient == null) {
      throw Exception("SSL Pinning not initialized. Call initSSLPinning() first.");
    }
    return _pinnedClient!;
  }
  // Returns the pinned client — used by ALL request methods
  http.Client get _client {
    _assertPinningVerified();
    return _pinnedClient!;
  }

  // Guard — throws if initSSLPinning() was never called
  void _assertPinningVerified() {
    if (!_isPinningVerified || _pinnedClient == null) {
      throw Exception("SSL Pinning not initialized. Call initSSLPinning() first.");
    }
  }

  // ---------------- GET ----------------
  Future<Map<String, dynamic>> get(String endpoint) async {
    _assertPinningVerified();
    final url = Uri.parse('${ApiConstants.baseURl}$endpoint');
    final response = await _client.get(url, headers: _defaultHeaders());
    return _handleResponse(response, 'GET');
  }

  // ---------------- POST ----------------
  Future<Map<String, dynamic>> post(String endpoint, {
    required Map<String, dynamic> body,
    required Map<String, String>? headers,
  }) async
  {
    _assertPinningVerified();
    final url = Uri.parse('${ApiConstants.baseURl}$endpoint');
    final response = await _client.post(
      url,
      headers: headers ?? _defaultHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response, 'POST');
  }

  // ---------------- COMMON HEADERS ----------------
  Map<String, String> _defaultHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // ---------------- RESPONSE HANDLER ----------------
  dynamic _handleResponse(http.Response response, String method) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'API Error [${response.statusCode}]: ${response.body}',
    );
  }

  // ---------------- API ENDPOINTS ----------------
}