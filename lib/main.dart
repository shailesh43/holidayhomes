import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './network/api_client.dart';
import './custom/screens/ssl_blocked_screen.dart';
import 'app.dart';

// Global singleton so app.dart uses the same initialized instance
final ApiClient globalApiClient = ApiClient();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".prod-env");

  // Initialize SSL pinning BEFORE app loads
  try {
    // await globalApiClient.initSSLPinning();
  } catch (e) {
    // Pinning failed — run blocked app instead
    runApp(const SslBlockedScreen());
    return;
  }

  runApp(const App());
}
