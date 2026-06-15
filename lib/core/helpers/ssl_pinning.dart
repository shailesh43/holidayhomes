import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holidayhomes/custom/screens/error/rogue_cert_screen.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SSLSecurity {
  static const _channel = MethodChannel('com.tatapower.holidayhomes/security');

  static Future<void> checkUserCACertificates(BuildContext context) async
  {
    if (!Platform.isAndroid) return;
    bool hasRogueCA = false;
    try {
      hasRogueCA = await _channel.invokeMethod('hasUserInstalledCACerts');
    } on PlatformException {
      // If the native check itself fails, fail safe — treat as compromised
      hasRogueCA = true;
    }

    if (!hasRogueCA) return;

    // Show blocking dialog — identical style to your existing showErrorDialog
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const RogueCertScreen(),
        ),
            (route) => false,
      );
    }

    // Throw so azure_auth_service.dart's login() catches it and returns null
    throw Exception('User-installed CA certificate detected — login blocked.');
  }

  static http.Client buildPinnedClient()
  {
    return _buildSecureClient();
  }

  static http.Client _buildSecureClient()
  {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
    return IOClient(ioClient);
  }
}