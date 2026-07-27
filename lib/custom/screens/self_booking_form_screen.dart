import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🚀 ADDED: To fetch logged-in user

import 'package:holidayhomes/main.dart';
import 'package:holidayhomes/network/api_client.dart'; // 🚀 ADDED: To use verifyEmployee
import 'package:holidayhomes/network/api_models/relation_response.dart';
import 'package:holidayhomes/network/api_models/send_mail_response.dart';
import 'booking_confirmation_screen.dart';

// ── 🛠️ Helper Class to manage dynamic rows ──
class GuestRowData {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  int? relationId;

  GuestRowData();
}

class SelfBookingFormScreen extends StatefulWidget {
  final Map<String, dynamic> propertyData;
  final int suiteId;
  final DateTime fromDate;
  final DateTime toDate;
  final int maxCapacity;

  const SelfBookingFormScreen({
    super.key,
    required this.propertyData,
    required this.suiteId,
    required this.fromDate,
    required this.toDate,
    this.maxCapacity = 6,
  });

  @override
  State<SelfBookingFormScreen> createState() => _SelfBookingFormScreenState();
}

class _SelfBookingFormScreenState extends State<SelfBookingFormScreen> {
  final ApiClient _client = globalApiClient; // 🚀 ADDED: Network client instance

  List<RelationData> _relations = [];
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final List<GuestRowData> _guestRows = [GuestRowData()];
  final TextEditingController _commentsController = TextEditingController();

  int? _selfRelationId;

  // 🚀 FIXED: Dynamic Employee Number (No longer final/hardcoded)
  String currentEmpNo = "";

  // 🚀 FIXED: Dynamic Hidden Payload Values
  String _empEmail = "test@tatapower.com";
  String _empMob = "9876543210";
  String _empDept = "Department";
  String _empDesig = "Designation";
  String _empCostCent = "CostCenter";

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  @override
  void dispose() {
    for (var row in _guestRows) {
      row.nameController.dispose();
      row.ageController.dispose();
    }
    _commentsController.dispose();
    super.dispose();
  }

  // 🚀 ADVANCED HELPER: Safely calculates Age from ANY Date format
  int _calculateAgeFromDOB(String dobStr) {
    try {
      DateTime? dob;

      // Handle ASP.NET / Microsoft JSON Date format: /Date(1234567890000)/
      if (dobStr.contains('/Date(')) {
        final msStr = dobStr.replaceAll(RegExp(r'[^0-9]'), '');
        if (msStr.isNotEmpty) {
          dob = DateTime.fromMillisecondsSinceEpoch(int.parse(msStr));
        }
      }

      // Standard Formats
      if (dob == null) { try { dob = DateTime.parse(dobStr); } catch (_) {} }
      if (dob == null) { try { dob = DateFormat("dd-MM-yyyy").parse(dobStr); } catch (_) {} }
      if (dob == null) { try { dob = DateFormat("MM/dd/yyyy").parse(dobStr); } catch (_) {} }
      if (dob == null) { try { dob = DateFormat("yyyyMMdd").parse(dobStr); } catch (_) {} }

      if (dob != null) {
        DateTime today = DateTime.now();
        int age = today.year - dob.year;
        if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
        return age;
      }
    } catch (e) {
      debugPrint("Error calculating age from DOB: $e");
    }
    return 0; // Fallback
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _guestRows[0].nameController.text = "Loading...";
    });

    try {
      // 1. Fetch Logged-in Employee Number from Storage
      final prefs = await SharedPreferences.getInstance();
      // NOTE: Update 'empNo' if your app saves it under a different key like 'SAP_EMP_NO' or 'userId'
      currentEmpNo = prefs.getString('empNo') ?? prefs.getString('SAP_EMP_NO') ?? "209164";

      // 2. Fetch Relations
      final relUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/dropdown?model=relation');
      final relResponse = await http.get(relUrl);

      if (relResponse.statusCode == 200) {
        final relationData = RelationResponse.fromJson(jsonDecode(relResponse.body));
        if (relationData.success == true) {
          _relations = relationData.data ?? [];
          try {
            final selfRel = _relations.firstWhere((r) => r.val.toLowerCase() == 'self');
            _selfRelationId = selfRel.key;
            _guestRows[0].relationId = _selfRelationId; // Lock first row to Self
          } catch (_) {}
        }
      }

      // 3. 🚀 Fetch Strongly Typed Employee Data using ApiClient
      final empResponse = await _client.verifyEmployee(empId: currentEmpNo);

      if (empResponse.data != null && empResponse.data!.isNotEmpty) {
        final emp = empResponse.data!.first;

        setState(() {
          // 🚀 Use sAPSHORTNAME explicitly as requested
          final name = emp.sAPSHORTNAME ?? emp.sAPDISPNAME ?? "Employee Name";
          _guestRows[0].nameController.text = name;

          // 🚀 Use sAPDOB explicitly to get age
          final dobStr = emp.sAPDOB;
          if (dobStr != null && dobStr.isNotEmpty) {
            int age = _calculateAgeFromDOB(dobStr);
            if (age > 0) {
              _guestRows[0].ageController.text = age.toString();
            } else {
              _guestRows[0].ageController.text = "";
            }
          }

          // 🚀 Populate hidden payload values dynamically from the backend
          _empEmail = emp.sAPEMAIL ?? _empEmail;
          _empMob = emp.sAPMOBILENO ?? _empMob;
          _empDept = emp.sAPORGUNITDESC ?? _empDept;
          _empDesig = emp.sAPCURRPOSITIONDESC ?? _empDesig;
          _empCostCent = emp.sAPCOSTCENTER ?? _empCostCent;
        });
      } else {
        setState(() { _guestRows[0].nameController.text = "User Not Found"; });
      }

    } catch (e) {
      debugPrint('Error fetching initial data: $e');
      setState(() { _guestRows[0].nameController.text = "Connection Error"; });
    } finally {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  void _addNewGuestRow() {
    if (_guestRows.length < widget.maxCapacity) {
      setState(() {
        _guestRows.add(GuestRowData());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum capacity of ${widget.maxCapacity} reached for this suite.'),
            backgroundColor: Colors.orange,
          )
      );
    }
  }

  void _removeGuestRow(int index) {
    if (index == 0) return; // Cannot remove the employee!
    setState(() {
      _guestRows[index].nameController.dispose();
      _guestRows[index].ageController.dispose();
      _guestRows.removeAt(index);
    });
  }

  Future<void> _submitBooking() async {
    for (var row in _guestRows) {
      if (row.nameController.text.trim().isEmpty || row.relationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill out Name and Relation for all guests.'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final propertyName = widget.propertyData['hdHomeName']?.toString() ?? 'Holiday Home';
      final String formattedFromDate = DateFormat("EEE, dd MMM yyyy '00:00:00 GMT'").format(widget.fromDate);
      final String formattedToDate = DateFormat("yyyy-MM-dd").format(widget.toDate);

      final checkUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/hdhmbookingcheck');
      final checkResponse = await http.post(
        checkUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "hdHomeBookingEmpno": currentEmpNo,
          "hdHomeBookingFromdt": formattedFromDate,
          "hdHomeBookingTodt": formattedToDate
        }),
      );
      final checkData = SendMailResponse.fromJson(jsonDecode(checkResponse.body));

      if (!checkData.success) {
        throw Exception('Booking check API failed entirely.');
      }

      List<Map<String, dynamic>> guestsPayload = _guestRows.map((row) {
        return {
          "guestName": row.nameController.text.trim(),
          "guestRelation": row.relationId.toString(),
          "guestAge": row.ageController.text.trim().isNotEmpty ? int.tryParse(row.ageController.text.trim()) : null
        };
      }).toList();

      final bookingUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/hdhmbooking');

      final Map<String, dynamic> bookingPayload = {
        "hdHomelocCd": widget.propertyData['hdHomeLocCd'] ?? 1,
        "hdHomeCd": widget.propertyData['hdHomeCd'] ?? 1,
        "hdHomeSuiteCd": widget.suiteId,
        "hdHomeSuiteCatg": widget.propertyData['hdHomeCat'] ?? 1,
        "hdHomeBookingEmpno": currentEmpNo,

        "hdHomeBookingEmpname": _guestRows[0].nameController.text,
        "hdHomeBookingEmpcostcent": _empCostCent,
        "hdHomeBookingEmpdept": _empDept,
        "hdHomeBookingEmpdesig": _empDesig,
        "hdHomeBookingEmpemail": _empEmail,
        "hdHomeBookingEmpmob": _empMob,
        "hdHomeBookingInsBy": currentEmpNo,

        "guests": guestsPayload,

        "hdHomeBookByEmail": _empEmail,
        "hdHomeBookByEmpName": _guestRows[0].nameController.text,
        "hdHomeBookByEmpno": currentEmpNo,
        "hdHomeBookingActive": "yes",
        "hdHomeBookingBy": "Self",
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

          final keysToTry = ['waitlistNumber', 'WaitlistNumber', 'waitlist_number', 'Waitlist_Number', 'waitlist', 'Waitlist', 'hdHomeBookingCurrwaiting', 'hd_home_booking_currwaiting'];

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
              MaterialPageRoute(builder: (context) => BookingConfirmationScreen(propertyName: propertyName, bookingId: bId, waitlistNumber: wNum)),
            );
          }
        } else {
          throw Exception(decoded['msg']?.toString() ?? 'Booking failed to save.');
        }
      } else {
        throw Exception('Server returned ${bookingResponse.statusCode}');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Complete Booking', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Add Guest Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 20),

                  ...List.generate(_guestRows.length, (index) {
                    bool isFirst = (index == 0);
                    var row = _guestRows[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: row.nameController,
                              readOnly: isFirst,
                              style: TextStyle(fontSize: 13, color: isFirst ? Colors.blue.shade900 : Colors.black, fontWeight: isFirst ? FontWeight.w600 : FontWeight.normal),
                              decoration: InputDecoration(
                                hintText: 'Guest Name',
                                filled: true,
                                fillColor: isFirst ? Colors.blue.shade50 : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: row.ageController,
                              readOnly: isFirst,
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 13, color: isFirst ? Colors.blue.shade900 : Colors.black, fontWeight: isFirst ? FontWeight.w600 : FontWeight.normal),
                              decoration: InputDecoration(
                                hintText: 'Age',
                                filled: true,
                                fillColor: isFirst ? Colors.blue.shade50 : Colors.white,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          Expanded(
                            flex: 3,
                            child: IgnorePointer(
                              ignoring: isFirst,
                              child: DropdownButtonFormField<int>(
                                value: row.relationId,
                                isExpanded: true,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                style: TextStyle(fontSize: 13, color: isFirst ? Colors.blue.shade900 : Colors.black, fontWeight: isFirst ? FontWeight.w600 : FontWeight.normal),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isFirst ? Colors.blue.shade50 : Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                items: _relations.isEmpty ? null : _relations.map((rel) {
                                  return DropdownMenuItem<int>(value: rel.key, child: Text(rel.val, overflow: TextOverflow.ellipsis));
                                }).toList(),
                                onChanged: (val) => setState(() => row.relationId = val),
                              ),
                            ),
                          ),

                          if (!isFirst)
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                              onPressed: () => _removeGuestRow(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    );
                  }),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _addNewGuestRow,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text('Add Another Guest (Max: ${widget.maxCapacity})'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _commentsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Additional Comments (Optional)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      hintText: 'Enter any special requests or notes here...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 15, color: Colors.blue)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Confirm Booking Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}