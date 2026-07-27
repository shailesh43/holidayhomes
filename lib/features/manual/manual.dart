import 'package:flutter/material.dart';

class PolicyPage extends StatefulWidget {
  const PolicyPage({super.key});

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  // Extract the primary blue color from the screenshot
  final Color primaryBlue = const Color(0xFF1976D2); // Assuming a standard Material Blue, adjust if needed based on exact hex from image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Manual',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Makes back button white
      ),
      backgroundColor: Colors.white, // Setting scaffold background to white
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Procedures & Guidelines',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryBlue, // Using the primary blue for the main heading
              ),
            ),
            const SizedBox(height: 20),
            _buildManualItem(
              title: 'Self Booking',
              description:
              'Enables eligible personnel to reserve holiday homes and suites. To secure a reservation, select the desired location, property type, and dates. Overall occupancy is governed by the maximum capacity of the selected suite.',
            ),
            _buildManualItem(
              title: 'Book for Others (Admin Only)',
              description:
              'Administrators are authorized to make reservations on behalf of other employees. The respective employee\'s ID is required to process these bookings.',
            ),
            _buildManualItem(
              title: 'Guest Booking',
              description:
              'Available across all locations, subject to standard guest booking policies and organizational guidelines.',
            ),
            _buildManualItem(
              title: 'Cancel Booking',
              description:
              'Allows users to cancel or rectify incorrect or unwanted reservations.',
            ),
            _buildManualItem(
              title: 'Search Booking',
              description:
              'Provides access to historical booking records, displaying comprehensive details of past and current reservations.',
            ),
            _buildManualItem(
              title: 'Print Intimation',
              description:
              'Facilitates the generation and printing of official booking confirmations using the unique booking reference number.',
            ),
            _buildManualItem(
              title: 'Edit Guest Details',
              description:
              'Permits modifications to guest information for existing reservations.',
            ),
            _buildManualItem(
              title: 'Admin Dashboard Overview',
              description:
              'Within the booking interface, administrators are granted global visibility, allowing them to view both their personal reservations and those made on behalf of other employees.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualItem({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // Slightly rounder corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15), // Subtle shadow
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.blue.shade100, width: 1), // Light blue border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: primaryBlue, size: 20), // Added an icon for visual appeal
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue, // Titles in blue
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87, // Darker text for readability against white
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
