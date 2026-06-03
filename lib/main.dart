import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './network/api_client.dart';
import 'app.dart';

// Global singleton so app.dart uses the same initialized instance
final ApiClient globalApiClient = ApiClient();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize SSL pinning BEFORE app loads
  try {
    await globalApiClient.initSSLPinning();
  } catch (e) {
    // Pinning failed — run blocked app instead
    runApp(const SSLBlockedApp());
    return;
  }

  runApp(const MyApp());
}

// Shown when SSL pinning fails
class SSLBlockedApp extends StatelessWidget {
  const SSLBlockedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Security Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'An untrusted certificate was detected.\nPlease remove user-installed CA certificates\nand restart the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}