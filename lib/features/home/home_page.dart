import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:holidayhomes/core/utils/enum.dart';
import '../../custom/widgets/action_card_wide.dart';
import '../../custom/widgets/action_button_square.dart';
import '../../core/utils/routes.dart';

// ── NEW IMPORTS FOR PROFILE & LOGOUT ──
import 'package:holidayhomes/core/constants/local_prefs.dart';
import 'package:holidayhomes/core/constants/api_constants.dart';
import 'package:holidayhomes/auth/azure_auth.dart';
import 'package:holidayhomes/app.dart';
import 'package:holidayhomes/main.dart'; // For globalApiClient

// ── MODELS ──
import 'package:holidayhomes/network/api_models/employee_response.dart';
import 'package:holidayhomes/network/api_models/post_response.dart';

class HomePage extends StatefulWidget {
  final UserRole role;
  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ── Profile Data State ──
  String? _empNo;
  String? _empName;
  String? _empRoleDesc;

  // ── Role-based access ──
  static const Map<String, List<UserRole>> _allowedRoles = {
    Routes.selfBooking: [UserRole.caretaker, UserRole.admin],
    Routes.othersBooking: [UserRole.admin],
    Routes.guestBooking: [UserRole.caretaker, UserRole.admin],
    Routes.cancelBooking: [UserRole.admin],
    Routes.printIntimation: [UserRole.caretaker, UserRole.admin],
    Routes.searchBooking: [UserRole.caretaker, UserRole.admin],
    Routes.editGuestDetails: [UserRole.caretaker, UserRole.admin],
  };

  bool _isAllowed(String route) {
    final roles = _allowedRoles[route];
    if (roles == null) return true;
    return roles.contains(widget.role);
  }

  void _navigateIfAllowed(String route) {
    if (!_isAllowed(route)) return;
    Navigator.pushNamed(context, route, arguments: widget.role);
  }

  // ── Carousel state ──
  static const int _virtualCount = 50000;
  late final PageController _pageController;

  int get _initialVirtualPage => (_virtualCount ~/ 2) -
      (_virtualCount ~/ 2) % _carouselItems.length;

  int _currentPage = 0;
  Timer? _autoScrollTimer;

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

    // 🚀 Fetch profile picture, name, and role immediately on load
    _loadUserProfile();
  }

  // ── Profile Fetch Logic ──
  Future<void> _loadUserProfile() async {
    final empNo = await LocalPrefs.getEmpCode();
    if (empNo == null || empNo.isEmpty) return;

    setState(() => _empNo = empNo);

    try {
      // 1. Fetch Employee Details for the Name
      final empRes = await globalApiClient.verifyEmployee(empId: empNo);

      // 🛠️ FIXED: Added != null and ! to handle nullable lists safely
      if (empRes.data != null && empRes.data!.isNotEmpty) {
        // Note: If you get a red line on 'sapDispName' here, change it to 'sAPDISPNAME' depending on how your model is typed!
        _empName = empRes.data!.first.sAPDISPNAME;
      }

      // 2. Fetch User Role using PostResponse Model
      final roleUrl = Uri.parse('${ApiConstants.baseURL}/master/dropdown?model=userrole&empno=$empNo');
      final roleHttpRes = await http.get(roleUrl);

      if (roleHttpRes.statusCode == 200) {
        final roleData = PostResponse.fromJson(jsonDecode(roleHttpRes.body));

        // 🛠️ FIXED: Added != null and ! to handle nullable lists safely
        if (roleData.data != null && roleData.data!.isNotEmpty) {
          _empRoleDesc = roleData.data!.first.key;
        }
      }
    } catch (e) {
      debugPrint('Failed to load profile data: $e');
    }

    if (mounted) setState(() {});
  }

  // ── Logout Logic ──
  Future<void> _handleLogout() async {
    await LocalPrefs.saveLoginStatus(isLoggedIn: false);
    await LocalPrefs.saveEmpCode(empCode: '');

    try {
      await AuthenticationService.logout(context);
    } catch (e) {
      debugPrint('Logout network error: $e');
    }

    if (!mounted) return;

    // Push new root to clear app state safely without breaking navigator
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
          (Route<dynamic> route) => false,
    );
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
                    Flexible(
                      child: Image.asset(
                        'assets/images/tata_power_full_logo.png',
                        height: 48,
                        fit: BoxFit.contain,
                        color: Colors.white,
                      ),
                    ),

                    // ── Profile Dropdown Menu ──
                    PopupMenuButton<String>(
                      offset: const Offset(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      elevation: 6,
                      onSelected: (String result) {
                        if (result == 'logout') _handleLogout();
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        // Profile Details Header (Non-clickable)
                        PopupMenuItem<String>(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _empName ?? 'Loading Profile...',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'EMP ID: ${_empNo ?? ''}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              if (_empRoleDesc != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _empRoleDesc!,
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade700
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        // Logout Button
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.redAccent, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // ── Profile Image ──
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromRGBO(255, 255, 255, 0.25),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _empNo == null
                            ? Image.asset('assets/images/user_login.jpg', fit: BoxFit.cover)
                            : Image.network(
                          '${ApiConstants.empProfileURL}/$_empNo.jpg',
                          fit: BoxFit.cover,
                          // If the URL fails or returns 404, safely fallback to local asset!
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/user_login.jpg', fit: BoxFit.cover);
                          },
                        ),
                      ),
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
                // Refresh profile data when the user pulls down
                await _loadUserProfile();
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
                                    color: Colors.black.withValues(alpha: 0.10),
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
                                    Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color.fromRGBO(200, 220, 255, 1),
                                        child: const Icon(
                                          Icons.image_outlined,
                                          size: 48,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(alpha: 0.60),
                                            ],
                                            stops: const [0.40, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
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

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ActionButtonSquare(
                            icon: Icons.home_outlined,
                            label: 'Self\nBooking',
                            enabled: _isAllowed(Routes.selfBooking),
                            onTap: () => _navigateIfAllowed(Routes.selfBooking),
                          ),
                          ActionButtonSquare(
                            icon: Icons.people_outline,
                            label: 'Book For\nothers',
                            enabled: _isAllowed(Routes.othersBooking),
                            onTap: () => _navigateIfAllowed(Routes.othersBooking),
                          ),
                          ActionButtonSquare(
                            icon: Icons.location_history_outlined,
                            label: 'Guest\nBooking',
                            enabled: _isAllowed(Routes.guestBooking),
                            onTap: () => _navigateIfAllowed(Routes.guestBooking),
                          ),
                          ActionButtonSquare(
                            icon: Icons.delete_outline,
                            label: 'Cancel\nBooking',
                            enabled: _isAllowed(Routes.cancelBooking),
                            onTap: () => _navigateIfAllowed(Routes.cancelBooking),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

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
                            enabled: _isAllowed(Routes.searchBooking),
                            onTap: () => _navigateIfAllowed(Routes.searchBooking),
                          ),
                          const Divider(
                            height: 0.5,
                            thickness: 1,
                            color: Color.fromRGBO(229, 231, 235, 1),
                          ),
                          ActionCardWide(
                            icon: Icons.print_outlined,
                            title: 'Print intimation',
                            subtitle: 'Get your booking Id intimation slip in pdf',
                            enabled: _isAllowed(Routes.printIntimation),
                            onTap: () => _navigateIfAllowed(Routes.printIntimation),
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
                            enabled: _isAllowed(Routes.editGuestDetails),
                            onTap: () => _navigateIfAllowed(Routes.editGuestDetails),
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