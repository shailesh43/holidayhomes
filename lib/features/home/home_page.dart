import 'package:flutter/material.dart';
import 'package:holidayhomes/core/utils/enum.dart';
import 'package:holidayhomes/custom/screens/search_bookings_screen.dart';
import 'package:holidayhomes/features/bookings/bookings_page.dart';
import '../../custom/widgets/action_card_wide.dart';
class HomePage extends StatefulWidget {
  final UserRole role;
  const HomePage({super.key, required this.role,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Holiday Homes Banner
          Container(
            height: 130,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.only(top: 30, bottom: 0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 100, 200, 0.75),
              border: Border.all(color: Colors.black, width: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Image.asset(
                      'assets/images/tata_power_full_logo.png',
                      height: 48,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Holiday Homes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: -0.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Home Page Content
          Expanded(
            child: RefreshIndicator(
              color: const Color.fromRGBO(41, 183, 69, 1),
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Locations

                    const SizedBox(height: 24),

                    // Action Buttons

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: Color.fromRGBO(0, 20, 69, 0.50),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Search Requests
                      ActionCardWide(
                        icon: Icons.search,
                        title: 'Search Bookings',
                        subtitle: 'Browse through all the bookings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SearchScreen(role: widget.role),
                            ),
                          );
                        },
                      ),
                      const Divider(
                        height: 0.5,
                        thickness: 1,
                        color: Color.fromRGBO(229, 231, 235, 1),
                      ),
                    ],
                ),
              ),
            ),
          ),
        ]
      )
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontFamily: 'Inter',
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

}


