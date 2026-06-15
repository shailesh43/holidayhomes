import 'package:flutter/material.dart';

// Custom
import '../widgets/detail_row.dart';
import '../../network/api_models/booking.dart';

class BookingsCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingsCard({
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${booking.hdHmTransSno?.toString()}" ?? '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_up,
                  size: 20,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            DetailRow(label: 'Holiday Home', value: booking.hdHomeName?.toString() ?? ''),
            DetailRow(label: 'Caretaker Contact', value: booking.hdHomeCaretakerMobile?.toString() ?? ''),
            DetailRow(label: 'EMP ID', value: booking.hdHomeBookingEmpno?.toString() ?? ''),
            DetailRow(label: 'EMP Name', value: booking.hdHomeBookingEmpname?.toString() ?? ''),
          ],
        ),
      ),
    );
  }
}