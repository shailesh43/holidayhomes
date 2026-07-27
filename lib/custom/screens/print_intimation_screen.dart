import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import 'package:holidayhomes/core/utils/enum.dart';
import 'package:holidayhomes/network/api_client.dart';
import 'package:holidayhomes/core/helpers/intimation_slip_pdf_builder.dart';
import 'package:holidayhomes/main.dart';

// ── CONNECTED MODELS ──
import 'package:holidayhomes/network/api_models/guest_info_response.dart';
import 'package:holidayhomes/network/api_models/booking_data_response.dart';

class PrintIntimation extends StatefulWidget {
  final UserRole role;
  const PrintIntimation({super.key, required this.role});

  @override
  State<PrintIntimation> createState() => _PrintIntimationState();
}

class _PrintIntimationState extends State<PrintIntimation> {
  final TextEditingController _bookingIdController = TextEditingController();
  final ApiClient _client = globalApiClient;

  bool _isLoading = false;
  String? _errorText;

  BookingData? _booking;
  List<GuestInfo> _guests = [];
  bool _expanded = false;

  Future<void> _onSubmit() async {
    final bookingId = _bookingIdController.text.trim();
    if (bookingId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Booking ID.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorText = null;
      _booking = null;
    });

    try {
      final response = await _client.findBookingById(bookingId: bookingId);

      if (response.success != true || response.data == null || response.data!.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorText = 'Booking not found.';
        });
        return;
      }

      final guestResponse = await _client.getGuestsInfo(bookingId: bookingId);

      if (!mounted) return;
      setState(() {
        _booking = response.data!.first;
        _guests = guestResponse.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = 'Error connecting to server.';
      });
    }
  }

  Future<File> _generatePdfFile() async {
    final doc = await IntimationSlipPdfBuilder.build(
      booking: _booking!,
      guests: _guests,
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/intimation_${_booking!.hdHmTransSno}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _onPreview() async {
    if (_booking == null) return;
    final doc = await IntimationSlipPdfBuilder.build(
      booking: _booking!,
      guests: _guests,
    );
    await Printing.layoutPdf(
      onLayout: (format) async => doc.save(),
    );
  }

  Future<void> _onDownload() async {
    if (_booking == null) return;
    final file = await _generatePdfFile();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved to ${file.path}'),
        backgroundColor: Colors.green,
      ),
    );

    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: 'intimation_${_booking!.hdHmTransSno}.pdf',
    );
  }

  @override
  void dispose() {
    _bookingIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
        foregroundColor: Colors.white,
        title: const Text(
          'Print Intimation',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please enter booking id',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),

            // ── Input Row (TextField + Search Button) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _bookingIdController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter Booking ID',
                      errorText: _errorText,
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Booking Summary Card ──
            if (_booking != null) ...[
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _booking!.hdHmTransSno?.toString() ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _detailRow('Holiday Home', _booking!.hdHomeName ?? 'N/A'),
                      _detailRow('Caretaker Contact', _booking!.hdHomeCaretakerMobile?.toString() ?? 'N/A'),
                      _detailRow('EMP ID', _booking!.hdHomeBookingEmpno?.toString() ?? 'N/A'),
                      _detailRow('EMP Name', _booking!.hdHomeBookingEmpname ?? 'N/A'),

                      if (_expanded) ...[
                        const Divider(height: 24),
                        _detailRow('Dept', _booking!.hdHomeBookingEmpdept ?? 'N/A'),
                        _detailRow('Suite', _booking!.hdHomeSuiteName ?? 'N/A'),
                        _detailRow('From Date', _booking!.hdHomeBookingFromdt ?? 'N/A'),
                        _detailRow('To Date', _booking!.hdHomeBookingTodt ?? 'N/A'),
                        _detailRow('Caretaker Name', _booking!.hdHomeCaretakername ?? 'N/A'),

                        if (_guests.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'Accompany Information',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          ..._guests.map(
                                (g) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${g.guestName} (${g.relName})'),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _onPreview,
                    icon: const Icon(Icons.remove_red_eye_outlined),
                    tooltip: 'Preview',
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton.icon(
                    onPressed: _onDownload,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Intimation Slip'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}