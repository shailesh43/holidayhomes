import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:holidayhomes/network/api_models/relation_response.dart';
import 'package:holidayhomes/network/api_models/send_mail_response.dart';
import 'booking_confirmation_screen.dart';

class GuestBookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> propertyData;
  final int suiteId;
  final DateTime fromDate;
  final DateTime toDate;

  const GuestBookingFormScreen({
    super.key,
    required this.propertyData,
    required this.suiteId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<GuestBookingFormScreen> createState() => _GuestBookingFormScreenState();
}

class _GuestBookingFormScreenState extends State<GuestBookingFormScreen> {
  int? _selectedRelationId;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  List<RelationData> _relations = [];
  bool _isLoadingRelations = true;
  bool _isSubmitting = false;

  final String currentEmpNo = "209164";

  @override
  void initState() {
    super.initState();
    _fetchRelations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _fetchRelations() async {
    try {
      final url = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/dropdown?model=relation');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final relationData = RelationResponse.fromJson(jsonDecode(response.body));
        if (mounted && relationData.success) {
          setState(() {
            _relations = relationData.data;
            _isLoadingRelations = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching relations: $e');
      if (mounted) setState(() => _isLoadingRelations = false);
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedRelationId == null || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final propertyName = widget.propertyData['hdHomeName']?.toString() ?? 'Holiday Home';

      final String formattedFromDate = DateFormat("EEE, dd MMM yyyy '00:00:00 GMT'").format(widget.fromDate);
      final String formattedToDate = DateFormat("yyyy-MM-dd").format(widget.toDate);

      final checkUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/hdhmbookingcheck');

      final Map<String, dynamic> checkPayload = {
        "hdHomeBookingEmpno": currentEmpNo,
        "hdHomeBookingFromdt": formattedFromDate,
        "hdHomeBookingTodt": formattedToDate
      };

      final checkResponse = await http.post(
        checkUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(checkPayload),
      );

      final checkData = SendMailResponse.fromJson(jsonDecode(checkResponse.body));

      if (!checkData.success) {
        throw Exception('Booking check API failed entirely.');
      }

      final bookingUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/hdhmbooking');

      final Map<String, dynamic> bookingPayload = {
        "hdHomelocCd": widget.propertyData['hdHomeLocCd'] ?? 1,
        "hdHomeCd": widget.propertyData['hdHomeCd'] ?? 1,
        "hdHomeSuiteCd": widget.suiteId,
        "hdHomeSuiteCatg": widget.propertyData['hdHomeCat'] ?? 1,
        "hdHomeBookingEmpno": currentEmpNo,

        "hdHomeBookingEmpname": "Employee Name",
        "hdHomeBookingEmpcostcent": "CostCenter",
        "hdHomeBookingEmpdept": "Department",
        "hdHomeBookingEmpdesig": "Designation",
        "hdHomeBookingEmpemail": "test@tatapower.com",
        "hdHomeBookingEmpmob": "9876543210",
        "hdHomeBookingInsBy": currentEmpNo,

        "guests": [
          {
            "guestName": _nameController.text.trim(),
            "guestRelation": _selectedRelationId.toString(),
            "guestAge": _ageController.text.trim().isNotEmpty ? int.tryParse(_ageController.text.trim()) : null
          }
        ],
        "hdHomeBookByEmail": "test@tatapower.com",
        "hdHomeBookByEmpName": "Employee Name",
        "hdHomeBookByEmpno": currentEmpNo,
        "hdHomeBookingActive": "yes",
        "hdHomeBookingBy": "For Guest",
        "hdHomeBookingCurrwaiting": 0,
        "hdHomeBookingFromdt": formattedFromDate,
        "hdHomeBookingTodt": formattedToDate,
        "hdHomeBookingWaiting": 0,
        "comments": _commentsController.text.trim()
      };

      final bookingResponse = await http.post(
        bookingUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingPayload),
      );

      if (bookingResponse.statusCode == 200 || bookingResponse.statusCode == 201) {

        final Map<String, dynamic> decoded = jsonDecode(bookingResponse.body);

        if (decoded['success'] == true) {

          String bId = "Pending";
          String wNum = "Confirmed (No Waitlist)";

          final keysToTry = [
            'waitlistNumber', 'WaitlistNumber', 'waitlist_number', 'Waitlist_Number',
            'waitlist', 'Waitlist', 'hdHomeBookingCurrwaiting', 'hd_home_booking_currwaiting'
          ];

          if (decoded['Bookingid'] != null) bId = decoded['Bookingid'].toString();
          if (decoded['bookingId'] != null) bId = decoded['bookingId'].toString();

          for (String key in keysToTry) {
            if (decoded[key] != null && decoded[key].toString() != "0" && decoded[key].toString() != "null") {
              wNum = decoded[key].toString();
              break;
            }
          }

          if (decoded['data'] != null && decoded['data'] is Map) {
            final dataMap = decoded['data'] as Map<String, dynamic>;

            if (dataMap['bookingId'] != null) bId = dataMap['bookingId'].toString();
            if (dataMap['Bookingid'] != null) bId = dataMap['Bookingid'].toString();

            for (String key in keysToTry) {
              if (dataMap[key] != null && dataMap[key].toString() != "0" && dataMap[key].toString() != "null") {
                wNum = dataMap[key].toString();
                break;
              }
            }
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(
                  propertyName: propertyName,
                  bookingId: bId,
                  waitlistNumber: wNum,
                ),
              ),
            );
          }
        } else {
          throw Exception(decoded['msg']?.toString() ?? 'Booking failed to save.');
        }
      } else {
        throw Exception('Server returned ${bookingResponse.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyName = widget.propertyData['hdHomeName']?.toString() ?? 'Holiday Home';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Complete Booking',
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
            Text(
              'Guest Details for $propertyName',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromRGBO(0, 100, 200, 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      labelText: 'Guest Full Name *',
                      labelStyle: const TextStyle(fontFamily: 'Inter'),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5)),
                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFamily: 'Inter'),
                    decoration: InputDecoration(
                      labelText: 'Guest Age (Optional)',
                      labelStyle: const TextStyle(fontFamily: 'Inter'),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5)),
                      prefixIcon: Icon(Icons.cake_outlined, color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _isLoadingRelations
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                    style: const TextStyle(fontFamily: 'Inter', color: Colors.black87),
                    decoration: const InputDecoration(
                      labelText: 'Relation to Employee *',
                      labelStyle: TextStyle(fontFamily: 'Inter'),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5)),
                    ),
                    value: _selectedRelationId,
                    items: _relations.isEmpty
                        ? null
                        : _relations.map((rel) {
                      return DropdownMenuItem<int>(
                        value: rel.key,
                        child: Text(rel.val),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedRelationId = val),
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _commentsController,
                    maxLines: 4,
                    style: const TextStyle(fontFamily: 'Inter'),
                    decoration: const InputDecoration(
                      labelText: 'Additional Comments (Optional)',
                      labelStyle: TextStyle(fontFamily: 'Inter'),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5)),
                      hintText: 'Enter any special requests or notes here...',
                      hintStyle: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm Booking Details', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}