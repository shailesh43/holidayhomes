import 'package:flutter/material.dart';
import 'package:holidayhomes/core/utils/enum.dart';
import 'package:holidayhomes/network/api_client.dart';
import 'package:holidayhomes/main.dart';
import 'package:holidayhomes/core/constants/local_prefs.dart';

import 'package:holidayhomes/network/api_models/my_bookings_response.dart';
import 'package:holidayhomes/network/api_models/facilitator_booking_response.dart';

class BookingsPage extends StatefulWidget {
  final UserRole role;
  const BookingsPage({super.key, required this.role});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final ApiClient _client = globalApiClient;
  String? _empNo;

  @override
  void initState() {
    super.initState();
    _loadEmpNo();
  }

  Future<void> _loadEmpNo() async {
    final empNo = await LocalPrefs.getEmpCode();
    setState(() {
      _empNo = empNo ?? '209164';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Bookings',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color.fromRGBO(0, 100, 200, 1.0),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
            tabs: [
              Tab(
                icon: Icon(Icons.person),
                text: 'My Bookings',
              ),
              Tab(
                icon: Icon(Icons.support_agent),
                text: 'Facilitator Booking',
              ),
            ],
          ),
        ),
        body: _empNo == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildMyBookingsSection(),
            _buildFacilitatorSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBookingsSection() {
    return FutureBuilder<MyBookingsResponse>(
      future: _client.getMyBookings(empNo: _empNo!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontFamily: 'Inter', color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return _buildEmptyState(Icons.event_note, 'Your personal bookings will appear here.');
        }

        final bookings = snapshot.data!.data;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(booking);
          },
        );
      },
    );
  }

  Widget _buildFacilitatorSection() {
    return FutureBuilder<FacilitatorBookingResponse>(
      future: _client.getFacilitatorBookings(empNo: _empNo!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontFamily: 'Inter', color: Colors.red)));
        } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
          return _buildEmptyState(Icons.assignment_ind, 'Facilitator bookings will appear here.');
        }

        final bookings = snapshot.data!.data;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return _buildBookingCard(booking);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Reverted to grey so it's visible on the white background
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final bookingId = booking['hd_hm_trans_sno']?.toString() ?? 'N/A';
    final propertyName = booking['hd_home_name'] ?? 'Unknown Property';
    final status = booking['booking_status'] ?? 'Pending';
    final guestName = booking['hd_home_booking_empname'] ?? 'Unknown Guest';
    final isCanceled = status.toString().toLowerCase().contains('cancel');

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color.fromRGBO(0, 100, 200, 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking ID: $bookingId',
                  style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 16, color: Color.fromRGBO(0, 100, 200, 1.0)),
                ),
                Container(
                  alignment: Alignment.center, // <-- Added for perfect alignment
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCanceled ? Colors.grey.shade200 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isCanceled ? Colors.grey.shade400 : Colors.green.shade200),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: isCanceled ? Colors.grey.shade700 : Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color.fromRGBO(0, 100, 200, 0.1)),
            Row(
              children: [
                const Icon(Icons.apartment, size: 20, color: Color.fromRGBO(0, 100, 200, 0.6)),
                const SizedBox(width: 8),
                Expanded(child: Text(propertyName, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black87))),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 20, color: Color.fromRGBO(0, 100, 200, 0.6)),
                const SizedBox(width: 8),
                Expanded(child: Text(guestName, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Colors.black87))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}