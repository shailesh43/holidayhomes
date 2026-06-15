import 'package:flutter/material.dart';

class SslBlockedScreen extends StatelessWidget {
  const SslBlockedScreen({super.key});

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