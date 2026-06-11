import 'package:flutter/material.dart';
import '../widgets/detail_row.dart';
import '../../network/api_models/booking.dart';
import '../../network/api_client.dart';
import 'dart:core';
import 'package:intl/intl.dart';
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


  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Delete Request',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this request?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF808080),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final request = widget.request;

              // Safety check: prefs must be loaded
              if (roleId == null || empCode == null) {
                _showSnackBar(
                  context: context,
                  message: 'Please wait, loading user details...',
                  isSuccess: false,
                );
                return;
              }

              Navigator.pop(context); // close confirmation dialog
              Navigator.pop(context); // close request details modal

              await _client.getStatusFilteredRequests(
                fromDate: '2026-01-12T00:00:00.000Z',
                toDate: '2026-07-03T23:59:59.000Z',
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    return BaseModal(
      request: request,
      title: request.hdHomeName ?? '',

      /// CONTENT
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailRow(label: 'Request ID', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Employee ID', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Employee Name', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Contact', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Email', value: widget.request.bookingStatus?.toLowerCase() ?? 'NULL'),
          // DetailRow(
          //   label: 'Date Of Request',
          //   value: widget.request.bookingStatus != null
          ///       ? DateFormat('dd/MM/yyyy').format(widget.request.hdHomeBookingInsDate!)
          //       : 'NULL',
          // ),
          DetailRow(label: 'Grade', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Eligibility', value: widget.request.bookingStatus?.toString() ?? 'NULL'),
          DetailRow(label: 'Cost Center', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Vehicle Model', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Manufactured by', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Vehicle Type', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Color', value: widget.request.bookingStatus ?? 'NULL'),
          DetailRow(label: 'Quotation', value: widget.request.bookingStatus?.toString() ?? 'NULL'),
          const SizedBox(height: 8),
          _buildStatusRow(request),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
          const SizedBox(height: 12),

          // ── Uploaded Documents Section ────────────────────────────
          const Text(
            'Uploaded Documents',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xF5323232),
            ),
          ),
          const SizedBox(height: 8),
          // asPage: false → no Scaffold/AppBar, shrinkWrapped ListView,
          // safe to embed inside this modal's scroll view.
        ],
      ),

      /// BOTTOM
      bottom: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showDeleteConfirmation(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(255, 227, 227, 1.0),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Delete Booking',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(250, 98, 98, 1.0),
              ),
            ),
          ),
        ),
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
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575)
          ),
        ),
        Text(
          request.bookingStatus ?? '',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
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