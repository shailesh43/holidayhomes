import 'package:flutter/material.dart';
import 'package:holidayhomes/core/utils/enum.dart';

class GuestBooking extends StatefulWidget {
  final UserRole  role;
  const GuestBooking({super.key, required this.role});

  @override
  State<GuestBooking> createState() => _GuestBookingState();
}

class _GuestBookingState extends State<GuestBooking> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
