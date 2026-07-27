import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 🛠️ ADDED: Import for the new booking form screen
import 'guest_booking_form_screen.dart';

// 🛠️ RENAMED class to PropertyOthersDetailsScreen to avoid conflicts
class PropertyOthersDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> propertyData;
  // 🚀 ADDED: Receiving the data from the first screen!
  final int suiteId;
  final DateTime fromDate;
  final DateTime toDate;

  const PropertyOthersDetailsScreen({
    super.key,
    required this.propertyData,
    required this.suiteId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  State<PropertyOthersDetailsScreen> createState() => _PropertyOthersDetailsScreenState();
}

class _PropertyOthersDetailsScreenState extends State<PropertyOthersDetailsScreen> {
  // Tabs: 0 for About, 1 for Things To do
  int _selectedTabIndex = 0;
  bool _isFetchingSuites = false;

  // ── Safely extract the "Things to do" from the API JSON ──
  List<Map<String, String>> get _thingsToDo {
    List<Map<String, String>> items = [];
    for (int i = 1; i <= 5; i++) {
      final title = widget.propertyData['hdHomeThingsToDoHeader$i']?.toString().trim() ?? '';
      final desc = widget.propertyData['hdThingsToDo$i']?.toString().trim() ?? '';
      final image = widget.propertyData['hdHomeThingsToDoImage$i']?.toString().trim() ?? '';

      if (title.isNotEmpty || desc.isNotEmpty) {
        items.add({'title': title, 'desc': desc, 'image': image});
      }
    }
    return items;
  }

  // ── Handle "Book Now" Button Click ──
  Future<void> _handleBookNow() async {
    final hdHomeId = widget.propertyData['hdHomeCd'];

    if (hdHomeId == null || hdHomeId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Property ID. Cannot proceed.', style: TextStyle(fontFamily: 'Inter'))),
      );
      return;
    }

    setState(() => _isFetchingSuites = true);

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Brief pause for UX

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestBookingFormScreen(
              propertyData: widget.propertyData,
              // 🚀 FIXED: Passing the data down to the form screen!
              suiteId: widget.suiteId,
              fromDate: widget.fromDate,
              toDate: widget.toDate,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server Error: $e', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isFetchingSuites = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final add1 = widget.propertyData['hdHomeAddress1']?.toString().trim() ?? '';
    final add2 = widget.propertyData['hdHomeAddress2']?.toString().trim() ?? '';
    String addressStr = [add1, add2].where((s) => s.isNotEmpty).join(', ');
    if (addressStr.isEmpty) addressStr = 'Address not available';

    final propertyName = widget.propertyData['hdHomeLocName']?.toString() ?? 'Property Details';

    String imageUrl = 'assets/images/places/${(propertyName == "Shirawata") ? "Sherowta" : propertyName}.jpg';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          propertyName,
          style: const TextStyle(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main Header Image ──
            Image.asset(
              imageUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                color: Colors.grey.shade100,
                child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title & Address ──
                  Text(
                    propertyName,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w600, color: Color.fromRGBO(0, 100, 200, 1.0)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addressStr,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                  ),
                  const SizedBox(height: 32),

                  // ── Custom Tabs ──
                  Row(
                    children: [
                      _buildTab(title: 'About', index: 0),
                      const SizedBox(width: 32),
                      _buildTab(title: 'Things To do', index: 1),
                    ],
                  ),
                  const Divider(height: 1, thickness: 2, color: Color.fromRGBO(0, 100, 200, 0.2)),
                  const SizedBox(height: 24),

                  // ── Tab Content ──
                  if (_selectedTabIndex == 0) _buildAboutTab() else _buildThingsToDoList(),

                  const SizedBox(height: 40),

                  // ── Booking Details ──
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color.fromRGBO(0, 100, 200, 0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Booking Details', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)), textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _isFetchingSuites ? null : _handleBookNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: _isFetchingSuites
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Book Now', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Booking is available from 9 AM to 11 PM',
                          style: TextStyle(fontFamily: 'Inter', color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String title, required int index}) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color.fromRGBO(0, 100, 200, 1.0) : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    final name = widget.propertyData['hdhomeContactPersonName']?.toString().trim() ?? 'Not Available';
    final email = widget.propertyData['hdhomeContactPersonEmail']?.toString().trim() ?? 'Not Available';
    final phone = widget.propertyData['hdhomeContactPersonMobile']?.toString().trim() ?? 'Not Available';
    final maxDays = widget.propertyData['hdhomeAdvanceDays']?.toString() ?? '30';

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Container(
              color: const Color.fromRGBO(0, 100, 200, 1.0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Row(
                children: const [
                  SizedBox(width: 130, child: Text('Care Taker Name', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  SizedBox(width: 200, child: Text('Care Taker Email', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  SizedBox(width: 150, child: Text('Contact Number', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                  SizedBox(width: 100, child: Text('Maximum Days', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                children: [
                  SizedBox(width: 130, child: Text(name, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black87))),
                  SizedBox(width: 200, child: Text(email, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black87))),
                  SizedBox(width: 150, child: Text(phone, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black87))),
                  SizedBox(width: 100, child: Text(maxDays, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black87))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThingsToDoList() {
    final items = _thingsToDo;

    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Text('No places to visit listed for this property.', style: TextStyle(fontFamily: 'Inter', color: Colors.grey)),
      );
    }

    return Column(
      children: items.map((item) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color.fromRGBO(0, 100, 200, 0.1)),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item['image']!,
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 120,
                      height: 90,
                      color: Colors.grey.shade100,
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item['title']!.isNotEmpty) ...[
                        Text(
                          '${item['title']}:',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        item['desc']!,
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.grey.shade800, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}