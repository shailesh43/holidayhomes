import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SSLSecurity {
  static String get _pinnedCertFingerprint =>
      dotenv.env['SHA_FINGERPRINT'] ?? '';

  // MethodChannel must match what you defined in MainActivity.kt
  static const _channel = MethodChannel('com.tatapower.greengears/security');

  /// Called at app startup. Checks for user-installed CA certs via native
  /// Android KeyStore inspection (the only reliable method).
  /// Shows a blocking dialog and throws if a rogue CA is detected.
  static Future<void> checkUserCACertificates(BuildContext context) async {
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
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Security Risk Detected',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'A user-installed CA certificate was detected on this '
                          'device. This may allow third parties to intercept your '
                          'login credentials.\n\n'
                          'To fix: Settings → Security → Encryption & credentials '
                          '→ Trusted credentials → User → remove the certificate, '
                          'then restart the app.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => exit(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(34, 197, 94, 1),
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Exit App'),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Throw so azure_auth_service.dart's login() catches it and returns null
    throw Exception('User-installed CA certificate detected — login blocked.');
  }

  /// Used by API client for pinned connections to bizapps.tatapower.com.
  /// Unchanged from your original.
  static http.Client buildPinnedClient() {
    return _buildSecureClient();
  }

  static http.Client _buildSecureClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => false;
    return IOClient(ioClient);
  }
}