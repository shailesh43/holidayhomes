import 'package:flutter/material.dart';
import 'package:holidayhomes/core/utils/enum.dart';

class HomePage extends StatefulWidget {
  final UserRole role;
  const HomePage({super.key, required this.role,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          const SizedBox(height: 100),
          Text('Login Successful.'),
          Text('Role: ${widget.role.name}'),
        ],
      )
    );
  }
}
