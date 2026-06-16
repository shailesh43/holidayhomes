import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:holidayhomes/network/api_models/booking.dart';
import 'package:holidayhomes/network/api_models/guest_info_response.dart';

/// Builds the Intimation Slip PDF, mirroring print-a.component.html
/// field-for-field, using the real Booking and GuestInfo models.
class IntimationSlipPdfBuilder {
  static Future<pw.Document> build({
    required Booking booking,
    required List<GuestInfo> guests,
  }) async {
    final doc = pw.Document();

    const companyName = 'The Tata Power Co. Ltd.';

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  companyName,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 14),

              pw.Center(
                child: pw.Text(
                  'Intimation Slip',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 18),

              // Details block (left) + photo placeholder (right)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 8),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _labelRow('Application No:',
                              booking.hdHmTransSno.toString()),
                          pw.SizedBox(height: 4),
                          _labelRow('Holiday Home:', booking.hdHomeName),
                          pw.SizedBox(height: 4),
                          _labelRow('Name:', booking.hdHomeBookingEmpname),
                          pw.SizedBox(height: 4),
                          _labelRow('Dept:', booking.hdHomeBookingEmpdept),
                        ],
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Align(
                      alignment: pw.Alignment.topRight,
                      // Photo skipped for now — placeholder box matching
                      // the ~12vh x 8vh image area from the HTML reference.
                      child: pw.Container(
                        width: 70,
                        height: 90,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.grey400, width: 0.7),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'Photo',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.grey500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 26),

              // To, caretaker block
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('To,'),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${booking.hdHomeCaretakername},${booking.hdHomeCaretakerMobile},',
                    ),
                    pw.Text('${booking.hdHomeName},'),
                    pw.SizedBox(height: 14),

                    // Allotment paragraph
                    pw.Text(
                      '${booking.hdHomeBookingEmpname} Employee Number ${booking.hdHomeBookingEmpno} '
                          '${booking.hdHomeBookingEmpdept} is allotted ${booking.hdHomeSuiteName}.'
                          'for a period of ${_computeDays(booking.hdHomeBookingFromdt, booking.hdHomeBookingTodt)} Days '
                          'from ${booking.hdHomeBookingFromdt}. (Check-in at 1.00 pm) '
                          'to ${booking.hdHomeBookingTodt}. (Check-out at 10.00 am).',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Accompany Information heading
              pw.Center(
                child: pw.Text(
                  'Accompany Information',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              // Guest table
              pw.Center(
                child: pw.Container(
                  width: 260,
                  child: pw.Table(
                    border: pw.TableBorder.all(
                        color: PdfColors.black, width: 0.7),
                    columnWidths: const {
                      0: pw.FlexColumnWidth(1.4),
                      1: pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          _tableHeaderCell('Name'),
                          _tableHeaderCell('Relationship'),
                        ],
                      ),
                      ...guests.map(
                            (g) => pw.TableRow(
                          children: [
                            _tableCell(g.guestName),
                            _tableCell(g.relName),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(height: 18),

              // Please Note section
              pw.Text(
                'Please Note:',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 14),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _bullet(
                      'The employee\u2019s presence with their company ID card is mandatory.',
                    ),
                    _bullet(
                      'Only names mentioned in the intimation slip will be allowed to the premises.',
                    ),
                    _bullet(
                      'The Accompany Information on this intimation slip includes children.',
                    ),
                    _bullet(
                      'Please ensure you enter the premise on day 1 by 10.00 pm and ensure the '
                          'caretaker confirms the booking in the system. Else the booking will stand '
                          'cancelled and the booking will be offered to the next person.',
                      fontSize: 7.5,
                    ),
                    _bullet(
                      'Employees are requested to submit their Government photo ID proof at the '
                          'time of check-in e.g. Aadhar card, Passport, Drivers License, Voters ID, etc.',
                      fontSize: 8,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),

              pw.Center(
                child: pw.Text(
                  'This is a computer generated statement. No signature required',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  static pw.Widget _labelRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  static pw.Widget _bullet(String text, {double fontSize = 8.5}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('\u2022  ', style: pw.TextStyle(fontSize: fontSize)),
          pw.Expanded(
            child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize)),
          ),
        ],
      ),
    );
  }

  /// Computes the number of days between fromDate and toDate. Booking's
  /// dates come through as Strings (hd_home_booking_fromdt / todt) — adjust
  /// the parse format below if your API returns something other than
  /// dd/MM/yyyy (e.g. ISO 8601 yyyy-MM-dd).
  static String _computeDays(String fromDate, String toDate) {
    try {
      final from = _parseDate(fromDate);
      final to = _parseDate(toDate);
      if (from == null || to == null) return '';
      return to.difference(from).inDays.toString();
    } catch (_) {
      return '';
    }
  }

  static DateTime? _parseDate(String input) {
    // Try dd/MM/yyyy first
    final slashParts = input.split('/');
    if (slashParts.length == 3) {
      final day = int.tryParse(slashParts[0]);
      final month = int.tryParse(slashParts[1]);
      final year = int.tryParse(slashParts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    // Fall back to ISO format (yyyy-MM-dd or full ISO 8601)
    return DateTime.tryParse(input);
  }
}