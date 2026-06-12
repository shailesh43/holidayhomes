import 'dart:async';
import 'package:flutter/material.dart';
import 'package:holidayhomes/core/utils/enum.dart';
import 'package:holidayhomes/custom/screens/search_bookings_screen.dart';
import '../../custom/widgets/action_card_wide.dart';
import '../../custom/widgets/action_button_square.dart';

class HomePage extends StatefulWidget {
  final UserRole role;
  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── Carousel state ─────────────────────────────────────────────────────────
  static const int _virtualCount = 50000;
  late final PageController _pageController;

  int get _initialVirtualPage => (_virtualCount ~/ 2) -
      (_virtualCount ~/ 2) % _carouselItems.length;  int _currentPage = 0;
  Timer? _autoScrollTimer;

  // Replace filenames / labels once real assets are added
  final List<Map<String, String>> _carouselItems = const [
    {'image': 'assets/images/places/Paradise_Village_Goa.jpg', 'location': 'Paradise Village, Goa'},
    {'image': 'assets/images/places/Lonavala.jpg', 'location': 'Lonavala'},
    {'image': 'assets/images/places/Sherowta.jpg', 'location': 'Sherowta'},
    {'image': 'assets/images/places/Mahale.jpg', 'location': 'Mahale'},
    {'image': 'assets/images/places/Mahabaleshwar.jpg', 'location': 'Mahabaleshwar'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.88,
      initialPage: _initialVirtualPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }
  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // ── Header Banner ──────────────────────────────────────────────────
          Container(
            height: 130,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 0),
            padding: const EdgeInsets.only(top: 30, bottom: 0),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(0, 100, 200, 1.0),
              border: Border.all(color: Colors.black, width: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tata Power logo
                  Flexible(
                    child: Image.asset(
                      'assets/images/tata_power_full_logo.png',
                      height: 48,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                  // User avatar (replaces "Holiday Homes" title)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 0.25),
                    backgroundImage: const AssetImage(
                      'assets/images/user_login.jpg',
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: null,
                  ),
                ],
              )
            ),
          ),

          // ── Scrollable Body ────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: const Color.fromRGBO(0, 100, 200, 0.75),
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Location Carousel ────────────────────────────────────
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 190,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _virtualCount,
                        onPageChanged: (virtualIndex) {
                          setState(() => _currentPage = virtualIndex % _carouselItems.length);
                        },
                        itemBuilder: (context, virtualIndex) {
                          final index = virtualIndex % _carouselItems.length;
                          final item = _carouselItems[index];
                          return AnimatedScale(
                            scale: _currentPage == index ? 1.0 : 0.95,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Background image
                                    Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color.fromRGBO(
                                            200, 220, 255, 1),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 48,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                    // Gradient overlay
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.60),
                                            ],
                                            stops: const [0.40, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Location label
                                    Positioned(
                                      left: 16,
                                      bottom: 16,
                                      child: Text(
                                        item['location']!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontStyle: FontStyle.normal,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black45,
                                              blurRadius: 4,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Dot Indicators ───────────────────────────────────────
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_carouselItems.length, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active
                                ? const Color.fromRGBO(0, 100, 200, 0.75)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // ── Primary Action Buttons ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionButtonSquare(
                            icon: Icons.home_outlined,
                            label: 'Self\nBooking',
                            onTap: () {},
                          ),
                          ActionButtonSquare(
                            icon: Icons.people_outline,
                            label: 'Book For\nothers',
                            onTap: () {},
                          ),
                          ActionButtonSquare(
                            icon: Icons.location_history_outlined,
                            label: 'Guest\nBooking',
                            onTap: () {},
                          ),
                          ActionButtonSquare(
                            icon: Icons.delete_outline,
                            label: 'Cancel\nBooking',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Quick Actions ────────────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                          color: Color.fromRGBO(0, 100, 200, 0.65),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          ActionCardWide(
                            icon: Icons.search,
                            title: 'Search Bookings',
                            subtitle: 'Browse through all the home bookings',
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
                          ActionCardWide(
                            icon: Icons.print_outlined,
                            title: 'Print intimation',
                            subtitle:
                            'Get your booking Id intimation slip in pdf',
                            onTap: () {},
                          ),
                          const Divider(
                            height: 0.5,
                            thickness: 1,
                            color: Color.fromRGBO(229, 231, 235, 1),
                          ),
                          ActionCardWide(
                            icon: Icons.person_add_alt_outlined,
                            title: 'Edit Guest Details',
                            subtitle: 'Add guests to your home booking',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}