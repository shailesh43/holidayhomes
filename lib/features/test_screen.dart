import 'package:flutter/material.dart';
import '../core/utils/enum.dart';

class TestScreen extends StatefulWidget {
  final UserRole role;

  const TestScreen({
    super.key,
    required this.role,
  });

  @override
  State<TestScreen> createState() => _TestScreen();
}

class _TestScreen extends State<TestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: Column(
        children: [
          const Text('Login Successful.'),
          Text('Role: ${widget.role.name}'),
        ],
      ),
    );
  }
}
