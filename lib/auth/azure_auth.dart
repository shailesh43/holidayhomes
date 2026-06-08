import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For PlatformException
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../core/constants/api_constants.dart';
import './token.dart';
import 'dart:io'; // For SocketException
import 'dart:async'; // For TimeoutException
import 'dart:convert'; // For jsonDecode
import '../core/helpers/ssl_pinning.dart';

http.Client _buildMicrosoftClient() {
  final httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Reject any cert that is NOT from a known Microsoft domain
      return host.endsWith('.microsoftonline.com') ||
          host.endsWith('.microsoft.com');
    };
  return IOClient(httpClient);
}


class AuthenticationService {
  // Nitish Sir Code for SAMAL Auth
  static Future<String?> login(BuildContext context) async {
    try {
      await SSLSecurity.checkUserCACertificates(context);
      final FlutterAppAuth appAuth = FlutterAppAuth();

      // AppAuth handles PKCE (S256) automatically — no manual implementation needed
      final AuthorizationTokenResponse? result =
      await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          ApiConstants.clientId,
          ApiConstants.redirectUri,
          // Correct: discovery document URL, not the authorization endpoint
          discoveryUrl:
          'https://login.microsoftonline.com/${ApiConstants.tenantId}/v2.0/.well-known/openid-configuration',
          scopes: ['User.Read', 'openid', 'profile', 'email', 'offline_access'],
          promptValues: ['select_account'],
        ),
      );

      if (result == null || result.accessToken == null) return null;

      assert(() {
        debugPrint('✅ Token exchange successful');
        return true;
      }());

      // Fetch employee ID from Microsoft Graph — same as existing flow
      final msClient = _buildMicrosoftClient();
      try {
        final userResponse = await msClient.get(
          Uri.parse(ApiConstants.userGraphUrl),
          headers: {
            'Authorization': 'Bearer ${result.accessToken}',
            'Content-Type': 'application/json',
          },
        );

        if (userResponse.statusCode != 200) {
          throw Exception('Failed to fetch user info: ${userResponse.statusCode}');
        }

        final userData = jsonDecode(userResponse.body);

        const extensionKey =
            'extension_6d1109881ca84719973dbff443d7b820_employeeNumber';
        final empId = userData[extensionKey]?.toString();

        if (empId == null || empId.isEmpty) {
          throw Exception('Employee ID not found in user profile');
        }

        return empId;
      } finally {
        msClient.close();
      }

    } on PlatformException catch (e)
    {
      if (e.code != 'CANCELED') {
        assert(() {
          debugPrint('❌ Platform error: ${e.code} - ${e.message}');
          return true;
        }());
      }
      return null;
    } on TimeoutException {
      return null;
    } on SocketException {
      return null;
    } catch (e, stackTrace) {
      assert(() {
        debugPrint('❌ Auth error: $e');
        debugPrint('Stack trace: $stackTrace');
        return true;
      }());
      return null;
    }
  }

  static Future<Token> refreshToken(
      BuildContext context, String? refreshToken) async
  {
    if (refreshToken == null) {
      final empId = await login(context);
      if (empId == null) {
        throw Exception('Login failed - unable to get employee ID');
      }
      throw Exception('No refresh token available - full login required');
    } else {
      final Map<String, dynamic> tokenParameters = {
        'client_id': ApiConstants.clientId,
        'scope': ApiConstants.scope,
        'refresh_token': refreshToken,
        'grant_type': 'refresh_token',
      };

      final msClient = _buildMicrosoftClient();
      try {
        final response = await msClient.post(
          Uri.parse(ApiConstants.tokenEndpoint),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: tokenParameters,
        );

        if (response.statusCode == 200) {
          return tokenFromJson(response.body);
        } else {
          throw Exception('Failed to refresh token');
        }
      } finally {
        msClient.close();
      }
    }
  }
}
