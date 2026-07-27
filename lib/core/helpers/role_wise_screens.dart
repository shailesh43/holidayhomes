import 'package:flutter/material.dart';
import 'package:holidayhomes/features/bookings/bookings_page.dart';
import 'package:holidayhomes/features/home/home_page.dart';
import 'package:holidayhomes/features/manual/manual.dart';

import '../../core/utils/enum.dart';
import '../constants/local_prefs.dart';

class RoleWiseScreens extends StatefulWidget {
  final UserRole role;

  const RoleWiseScreens({
    super.key,
    required this.role,
  });

  @override
  State<RoleWiseScreens> createState() => _RoleWiseScreensState();
}

class _RoleWiseScreensState extends State<RoleWiseScreens> {
  int _selectedIndex = 0;
  bool isLoading = true;
  String empId = '';
  int roleId = 0;
  late final UserRole role;

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  Future<int> getUserRole() async {
    int? rId = await LocalPrefs.getRoleId();
    return rId ?? 0;
  }

  @override
  void initState() {
    role = widget.role;
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final code = await LocalPrefs.getEmpCode();
    setState(() {
      empId = code ?? '';
    });
    int rId = await getUserRole();
    setState(() {
      roleId = rId;
    });
    _setupPagesAndNav();
    setState(() {
      isLoading = false;
    });
  }

  void _setupPagesAndNav() {

    const threeTabNav = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
      BottomNavigationBarItem(icon: Icon(Icons.policy), label: 'Policy'),
    ];

    const twoTabNav = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.policy), label: 'Policy'),
    ];

    switch (role)
    {
      case UserRole.admin:
        _pages = [
          HomePage(role: role), // Home
          BookingsPage(role: role), // Bookings
          const PolicyPage(), // Policy
        ];
        break;

      case UserRole.caretaker:
        _pages = [
          HomePage(role: role), // Home
          const PolicyPage(), // policy
        ];
        break;

      case UserRole.facilitator:
        _pages = [
          HomePage(role: role), // Home
          BookingsPage(role: role), // Bookings
          const PolicyPage(), // Policy
        ];
        break;

      case UserRole.report:
        _pages = [
          HomePage(role: role), // Home
          BookingsPage(role: role), // Bookings
          const PolicyPage(), // Policy
        ];
        break;
    }

    _navItems = _pages.length == 3
        ?  threeTabNav
        : twoTabNav;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromRGBO(34, 116, 197, 1.0), // Your green color
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: _navItems,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        backgroundColor: const Color.fromRGBO(248, 248, 248, 0.75),
        selectedItemColor: const Color.fromRGBO(0, 0, 0, 0.75),
      ),
    );
  }
}