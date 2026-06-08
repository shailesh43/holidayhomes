import 'package:flutter/material.dart';
import 'package:holidayhomes/core/utils/enum.dart';

class BookingsPage extends StatefulWidget {
  final UserRole role;
  const BookingsPage({super.key, required this.role});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
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
