import 'package:flutter/material.dart';

import 'package:holidayhomes/network/api_client.dart';
import 'package:holidayhomes/main.dart';
import 'package:holidayhomes/network/api_models/booking_data_response.dart';
import 'package:holidayhomes/network/api_models/status_message_response.dart';
import 'package:holidayhomes/network/api_models/booking_result_response.dart';

class CancelBookingScreen extends StatefulWidget {
  const CancelBookingScreen({super.key});

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  final ApiClient _client = globalApiClient;
  final TextEditingController _bookingIdController = TextEditingController();

  bool _isSearching = false;
  bool _isCancelling = false;
  BookingData? _bookingDetails;

  @override
  void dispose() {
    _bookingIdController.dispose();
    super.dispose();
  }

  Future<void> _searchBooking() async {
    final enteredId = _bookingIdController.text.trim();

    if (enteredId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Booking ID.', style: TextStyle(fontFamily: 'Inter'))),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _bookingDetails = null;
    });

    try {
      final BookingDataResponse response = await _client.findBookingById(bookingId: enteredId);

      if (mounted) {
        setState(() => _isSearching = false);

        if (response.success == true && response.data != null && response.data!.isNotEmpty) {
          setState(() {
            _bookingDetails = response.data!.first;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No booking found with this ID.', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network Error: $e', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCancellationDialog() async {
    final TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cancel Booking', style: TextStyle(fontFamily: 'Inter', color: Color.fromRGBO(0, 100, 200, 1.0), fontSize: 18, fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
          content: TextField(
            controller: reasonController,
            maxLines: 5,
            style: const TextStyle(fontFamily: 'Inter'),
            decoration: const InputDecoration(
              hintText: 'Enter Cancellation Reason',
              hintStyle: TextStyle(fontFamily: 'Inter'),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a cancellation reason.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.orange),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                _processCancellation(reason);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F), // Kept red for destructive action
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Text('Submit', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _processCancellation(String reason) async {
    if (_bookingDetails == null) return;

    setState(() => _isCancelling = true);

    try {
      final bookingId = _bookingDetails!.hdHmTransSno.toString();

      final StatusMessageResponse mailResponse = await _client.sendCancellationMail(
        bookingId: bookingId,
        reason: reason,
      );

      final BookingResultResponse cancelResponse = await _client.submitCancelBookingWithReason(
        bookingId: bookingId,
        reason: reason,
      );

      if (mounted) {
        setState(() => _isCancelling = false);

        if (cancelResponse.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your booking has been cancelled', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            _bookingDetails = null;
            _bookingIdController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel the booking on the server.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cancellation Process Failed: $e', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cancel Booking',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please enter booking id',
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _bookingIdController,
                    enabled: !_isSearching && !_isCancelling,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      hintText: 'Enter Booking ID',
                      hintStyle: const TextStyle(fontFamily: 'Inter'),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: (_isSearching || _isCancelling) ? null : _searchBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSearching
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Search', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                ),
              ],
            ),

            const SizedBox(height: 32),

            if (_bookingDetails != null) ...[
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color.fromRGBO(0, 100, 200, 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booking Summary',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)),
                      ),
                      const Divider(height: 24, thickness: 1, color: Color.fromRGBO(0, 100, 200, 0.2)),
                      _buildDetailRow('Location:', _bookingDetails!.hdLocName),
                      _buildDetailRow('Property:', _bookingDetails!.hdHomeName),
                      _buildDetailRow('Suite:', _bookingDetails!.hdHomeSuiteName),
                      _buildDetailRow('Guest:', _bookingDetails!.hdHomeBookingEmpname),
                      _buildDetailRow('Dates:', '${_bookingDetails!.hdHomeBookingFromdt}  to  ${_bookingDetails!.hdHomeBookingTodt}'),
                      _buildDetailRow('Status:', _bookingDetails!.bookingStatus, isStatus: true),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isCancelling ? null : _showCancellationDialog,
                          icon: _isCancelling
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.cancel_outlined),
                          label: Text(_isCancelling ? 'Processing...' : 'Cancel This Booking', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600, // Kept red for destructive action
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                color: isStatus ? Colors.orange.shade700 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}