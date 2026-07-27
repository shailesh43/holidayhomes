import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

// Standard Relative Imports (Matches your exact folder structure)
import 'auth/azure_auth.dart';
import 'core/constants/local_prefs.dart';
import 'network/api_client.dart';
import 'core/utils/enum.dart';
import 'core/helpers/role_wise_screens.dart';
import 'core/helpers/emulator_detector.dart';
import 'core/utils/routes.dart';
import 'main.dart'; // Gives access to globalApiClient

// Screen Imports
import 'custom/screens/self_booking_screen.dart';
import 'custom/screens/book_for_others_screen.dart';
import 'custom/screens/guest_booking_screen.dart';
import 'custom/screens/cancel_booking_screen.dart';
import 'custom/screens/print_intimation_screen.dart';
import 'custom/screens/search_bookings_screen.dart';
import 'custom/screens/edit_guest_details_screen.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

enum _LoginResult { success, cancelled, failed }

class _InitResult {
  final String? empId;
  final _LoginResult loginResult;
  const _InitResult.success(this.empId) : loginResult = _LoginResult.success;
  const _InitResult.cancelled()
      : empId = null,
        loginResult = _LoginResult.cancelled;
  const _InitResult.failed()
      : empId = null,
        loginResult = _LoginResult.failed;
  const _InitResult.emulatorBlocked()
      : empId = "EMULATOR_BLOCKED",
        loginResult = _LoginResult.success;
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Uses globalApiClient from main.dart to ensure SSL pinning remains active
  final ApiClient _client = globalApiClient;

  late Future<_InitResult> _initFuture;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAssets(context);
    });
  }

  Future<void> _preloadAssets(BuildContext context) async {
    await precacheImage(
      const AssetImage('assets/images/tata_power_full_logo.png'),
      context,
    );
  }

  Future<_InitResult> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (Platform.isAndroid) {
      final isRoot = await androidRootChecker();
      final isDeveloperMode = await developerMode();
      final isEmulatorDevice = await isEmulator();
      final hasSuspiciousStorage = await suspiciousStorageCheck();

      bool hasRogueCA = false;
      if (!kDebugMode) {
        try {
          hasRogueCA = await const MethodChannel('com.tatapower.holidayhomes/security')
              .invokeMethod('hasUserInstalledCACerts');
        } on PlatformException {
          hasRogueCA = true; // fail safe
        }
      }

      if (!isRoot && !isDeveloperMode && !isEmulatorDevice && !hasRogueCA) {
        return await moveToNext();
      } else {
        if (isRoot) {
          showErrorDialog('You cannot use the Tata Power GreenGears app on a jailbroken or rooted device.');
        } else if (isDeveloperMode) {
          showErrorDialog(
            'Developer Mode is enabled, preventing you from using the app. '
                'To disable it, go to Settings > search for Developer > select '
                'Developer options > toggle it Off, then restart the app.',
          );
        } else if (isEmulatorDevice) {
          showErrorDialog('The Tata Power GreenGears app cannot run on an emulator. Please install the app on a physical device.');
        } else if (hasRogueCA) {
          showErrorDialog('A user-installed CA certificate was detected on this device.');
        }
        return const _InitResult.emulatorBlocked();
      }
    } else if (Platform.isIOS) {
      // iOS block unchanged
      final isIosJailbreak = await iosJailbreak();
      final isEmulatorDevice = await isEmulator();

      if (!isIosJailbreak && !isEmulatorDevice) {
        return await moveToNext();
      } else {
        if (isIosJailbreak) {
          showErrorDialog('You cannot use the Tata Power GreenGears app on a jailbroken or rooted device.');
        } else if (isEmulatorDevice) {
          showErrorDialog('The Tata Power GreenGears app cannot run on an emulator. Please install the app on a physical device.');
        }
        return const _InitResult.emulatorBlocked();
      }
    }
    return await moveToNext();
  }

  Future<_InitResult> moveToNext() async {
    final storedEmpId = await LocalPrefs.getEmpCode();
    if (storedEmpId != null && storedEmpId.isNotEmpty) {
      return _InitResult.success(storedEmpId);
    }
    return _login();
  }

  Future<bool> androidRootChecker() async {
    if (kDebugMode) return false;
    try {
      return await JailbreakRootDetection.instance.isJailBroken;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> isEmulator() async {
    if (kDebugMode) return false;

    try {
      return await EmulatorDetector.isEmulator();
    } catch (e) {
      return false;
    }
  }

  Future<bool> suspiciousStorageCheck() async {
    try {
      return !(await JailbreakRootDetection.instance.isOnExternalStorage);
    } catch (e) {
      return false;
    }
  }

  Future<bool> developerMode() async {
    if (kDebugMode) return false;
    try {
      return await JailbreakRootDetection.instance.isDevMode;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> iosJailbreak() async {
    if (kDebugMode) return false;
    try {
      const bundleId = 'com.tatapower.holidayhomes';
      return await JailbreakRootDetection.instance.isJailBroken ||
          await JailbreakRootDetection.instance.isTampered(bundleId);
    } on PlatformException {
      return false;
    }
  }

  void showErrorDialog(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _navigatorKey.currentContext;
      if (ctx == null) return;

      showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      message,
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => exit(0),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(250, 98, 98, 1.0),
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Exit App'),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<_InitResult> _login() async {
    final empId = await AuthenticationService.login(context);
    if (empId != null) {
      await LocalPrefs.saveEmpCode(empCode: empId);
      await LocalPrefs.saveLoginStatus(isLoggedIn: true);
      return _InitResult.success(empId);
    }

    return const _InitResult.cancelled();
  }

  Future<UserRole> _fetchEmployeeRole(String empCode) async {
    if (empCode.isEmpty) return UserRole.caretaker;
    try {
      await LocalPrefs.saveRoleId(roleId: 1);
      return UserRole.fromId(1) ?? UserRole.caretaker;
    } catch (e) {
      assert(() {
        debugPrint('Error fetching role: $e');
        return true;
      }());
      return UserRole.caretaker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Holiday Homes',
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      navigatorObservers: [routeObserver],

      routes: {
        // ── 🛠️ FIXED: Reverted to simple routing without arguments! ──
        Routes.selfBooking: (context) => const SelfBookingScreen(),
        Routes.othersBooking: (context) => const BookForOthersScreen(),
        Routes.guestBooking: (context) => const GuestBookingScreen(),
        Routes.cancelBooking: (context) => const CancelBookingScreen(),
        Routes.printIntimation: (context) => const PrintIntimation(role: UserRole.caretaker),
        Routes.searchBooking: (context) => const SearchBooking(role: UserRole.caretaker),
        Routes.editGuestDetails: (context) => const EditGuestDetails(role: UserRole.caretaker),
      },

      home: FutureBuilder<_InitResult>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          final result = snapshot.data;

          if (result?.empId == "EMULATOR_BLOCKED") {
            return const Scaffold(
              body: Center(
                child: Text(
                  "This app cannot run on an emulator.",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }

          if (result?.loginResult == _LoginResult.success &&
              result?.empId != null) {
            final empCode = result!.empId!;
            return FutureBuilder<UserRole>(
              future: _fetchEmployeeRole(empCode),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(34, 197, 94, 1),
                      ),
                    ),
                  );
                }
                final role = roleSnapshot.data ?? UserRole.caretaker;
                return RoleWiseScreens(role: role);
              },
            );
          }

          final isCancelled = result?.loginResult == _LoginResult.cancelled;
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isCancelled) ...[
                    const Text(
                      '404 :(',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.8,
                        color: Colors.redAccent,
                      ),
                    ),
                    const Text(
                      'Error! Login failed. Please try again.',
                      style: TextStyle(
                        fontSize: 18,
                        letterSpacing: -0.2,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (isCancelled)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Sign in to continue.',
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: -0.2,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _initFuture = _login();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.80),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.20),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color.fromRGBO(80, 80, 80, 1.0),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Splash Screen Widget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/tata_power_full_logo.png',
                height: 80,
                color: const Color.fromRGBO(22, 100, 162, 1.0),
              ),
              const SizedBox(height: 32),
              const Text(
                'Holiday Homes',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.8,
                  color: Color.fromRGBO(72, 72, 72, 0.9607843137254902),
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          SizedBox(
            width: double.infinity,
            height: 100,
            child: Lottie.asset(
              'assets/images/house_animation.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }
}