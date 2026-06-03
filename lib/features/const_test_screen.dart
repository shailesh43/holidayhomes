import 'package:flutter/material.dart';
import '../core/utils/enum.dart';

class ConstTestScreen extends StatelessWidget {
  const ConstTestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Static Test Screen'),
      ),
      body: Column(
        children: [
          const Text('Static Data.'),
        ],
      ),
    );
  }
}
