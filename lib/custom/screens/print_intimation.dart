import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import 'package:holidayhomes/core/utils/enum.dart';
import 'package:holidayhomes/custom/widgets/form_text_field.dart';
import 'package:holidayhomes/network/api_models/booking.dart';
import 'package:holidayhomes/network/api_models/guest_info_response.dart';
import 'package:holidayhomes/network/api_client.dart'; // adjust to your actual client path
import 'package:holidayhomes/core/helpers/intimation_slip_pdf_builder.dart';

class PrintIntimation extends StatefulWidget {
  final UserRole role;
  const PrintIntimation({super.key, required this.role});

  @override
  State<PrintIntimation> createState() => _PrintIntimationState();
}

class _PrintIntimationState extends State<PrintIntimation> {
  final TextEditingController _bookingIdController = TextEditingController();
  final ApiClient _client = ApiClient();

  bool _isLoading = false;
  String? _errorText;

  Booking? _booking;
  List<GuestInfo> _guests = [];
  bool _expanded = false;

  Future<void> _onSubmit() async {
    final bookingId = _bookingIdController.text.trim();

    if (bookingId.isEmpty) {
      setState(() => _errorText = 'Booking Id is required');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
      _booking = null;
      _guests = [];
      _expanded = false;
    });

    try {
      final bookingResponse = await _client.findBookingById(bookingId: bookingId);

      if (!bookingResponse.success || bookingResponse.data.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorText = 'Booking not found. Please check the Booking Id.';
        });
        return;
      }

      final guestResponse = await _client.getGuestsInfo(bookingId: bookingId);

      if (!mounted) return;
      setState(() {
        _booking = bookingResponse.data.first;
        _guests = guestResponse.success ? guestResponse.data : [];
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      print('ERROR: $e');
      print('STACK: $stackTrace');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Booking not found. Please check the Booking Id.';
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
    final file =
    File('${dir.path}/intimation_${_booking!.hdHmTransSno}.pdf');
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
      SnackBar(content: Text('Saved to ${file.path}')),
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
      appBar: AppBar(title: const Text('Print Intimation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormTextField(
              label: 'Booking Id',
              hint: 'Enter Booking Id',
              required: true,
              controller: _bookingIdController,
              errorText: _errorText,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmit,
                child: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text('Submit'),
              ),
            ),
            const SizedBox(height: 24),
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
                            _booking!.hdHmTransSno.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _detailRow('Holiday Home', _booking!.hdHomeName),
                      _detailRow('Caretaker Contact',
                          _booking!.hdHomeCaretakerMobile.toString()),
                      _detailRow(
                          'EMP ID', _booking!.hdHomeBookingEmpno.toString()),
                      _detailRow('EMP Name', _booking!.hdHomeBookingEmpname),
                      if (_expanded) ...[
                        const Divider(height: 24),
                        _detailRow('Dept', _booking!.hdHomeBookingEmpdept),
                        _detailRow('Suite', _booking!.hdHomeSuiteName),
                        _detailRow('From Date', _booking!.hdHomeBookingFromdt),
                        _detailRow('To Date', _booking!.hdHomeBookingTodt),
                        _detailRow(
                            'Caretaker Name', _booking!.hdHomeCaretakername),
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
                              child:
                              Text('${g.guestName} (${g.relName}', style:),
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