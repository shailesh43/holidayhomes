import 'package:flutter/material.dart';
import '../widgets/detail_row.dart';
import '../../network/api_models/booking.dart';
import '../../network/api_client.dart';
import 'dart:core';
import './base_modal.dart';
class BookingsDetailsModal extends StatefulWidget {
  final Booking request;

  const BookingsDetailsModal({
    super.key,
    required this.request,
  });

  @override
  State<BookingsDetailsModal> createState() =>
      _BookingsDetailsModalState();
}

class _BookingsDetailsModalState extends State<BookingsDetailsModal> {

  String? empCode;
  int? roleId;
  String? requestId;

  final ApiClient _client = ApiClient();

  @override
  void initState() {
    super.initState();
  }

  String calculateBookingDays(String fromDate, String toDate) {
    final from = DateTime.parse(fromDate);
    final to = DateTime.parse(toDate);

    // +1 because bookings usually include both start and end dates
    return "${to.difference(from).inDays + 1} days";
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return BaseModal(
      request: request,
      title: "Booking ID: ${request.hdHmTransSno.toString()}" ?? '',

      /// CONTENT
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Location', value: widget.request.hdLocName.toString() ?? 'NULL'),
          DetailRow(label: 'Holiday Home', value: widget.request.hdHomeName.toString() ?? 'NULL'),
          DetailRow(label: 'Suite Name', value: widget.request.hdHomeSuiteName.toString() ?? 'NULL'),
          DetailRow(label: 'Caretaker Name', value: widget.request.hdHomeCaretakername.toString() ?? 'NULL'),
          DetailRow(label: 'Caretaker Email', value: widget.request.hdHomeCaretakerEmail.toString() ?? 'NULL'),
          DetailRow(label: 'Caretaker Mobile', value: widget.request.hdHomeCaretakerMobile.toString() ?? 'NULL'),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
          const SizedBox(height: 12,),
          DetailRow(label: 'Employee Name', value: widget.request.hdHomeBookingEmpname ?? 'NULL'),
          DetailRow(label: 'Employee Email', value: widget.request.hdHomeBookingEmpemail ?? 'NULL'),
          DetailRow(label: 'Employee Code', value: widget.request.hdHomeBookingEmpno.toString() ?? 'NULL'),
          DetailRow(label: 'From', value: widget.request.hdHomeBookingFromdt.toString() ?? 'NULL'),
          DetailRow(label: 'To', value: widget.request.hdHomeBookingTodt.toString() ?? 'NULL'),
          DetailRow(label: 'Number of Days', value: calculateBookingDays(widget.request.hdHomeBookingFromdt, widget.request.hdHomeBookingTodt).toString() ?? 'NULL'),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
          const SizedBox(height: 12),
          _buildStatusRow(request),
        ],
      ),
    );
  }

  Widget _buildStatusRow(Booking request) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Status',
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575)
          ),
        ),
        Text(
          request.bookingStatus ?? '',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  void _showSnackBar({
    required BuildContext context,
    required String message,
    required bool isSuccess,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSuccess
                ? const Color(0xFF388E3B)
                : const Color(0xFFFA6262),
          ),
        ),
        backgroundColor: isSuccess
            ? const Color(0xFFD7FFD8)
            : const Color(0xFFFFE3E3),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}