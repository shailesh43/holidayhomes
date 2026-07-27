import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:holidayhomes/network/api_client.dart';
import 'package:holidayhomes/main.dart';

import 'package:holidayhomes/network/api_models/location_response.dart' as loc_model;
import 'package:holidayhomes/network/api_models/base_api_response.dart';
import 'package:holidayhomes/network/api_models/hddetails_response.dart';
import 'package:holidayhomes/network/api_models/hdhmbookingdetailsNext30days_response.dart';
import 'package:holidayhomes/network/api_models/hdmbookingcheckavail_response.dart';
import 'package:holidayhomes/network/api_models/select_holiday_home_response.dart';
import 'package:holidayhomes/network/api_models/suite_response.dart';

import 'property_self_details_screen.dart';

class SelfBookingScreen extends StatefulWidget {
  const SelfBookingScreen({super.key});

  @override
  State<SelfBookingScreen> createState() => _SelfBookingScreenState();
}

class _SelfBookingScreenState extends State<SelfBookingScreen> {
  final ApiClient _client = globalApiClient;

  int? _selectedLocationId;
  String? _selectedLocationName;
  int? _selectedHHId;
  int? _selectedSuiteId;
  DateTimeRange? _selectedDateRange;

  List<loc_model.LocationData> _apiLocations = [];
  List<loc_model.LocationData> _apiHolidayHomes = [];
  List<loc_model.LocationData> _apiSuites = [];

  List<SuiteData> _rawSuitesData = [];
  List<DateTime> _bookedDates = [];

  // Data for Calendar Grid
  List<HdmbookingcheckavailItem> _availabilityCalendar = [];

  // Bulletproof String Map for Grid Colors
  Map<String, String> _dateColorMap = {};

  // Data for Table
  List<HdhmbookingdetailsNext30daysItem> _next30DaysDetails = [];

  bool _isLoadingAvailability = false;

  Map<String, dynamic>? _propertyCardData;

  int _maxAllowedDays = 30;
  int _maxCapacity = 6;

  final String currentEmpNo = "209164";
  String _employeeGrade = "ME03";

  bool _isLoadingLocations = true;
  bool _isLoadingHHs = false;
  bool _isLoadingSuites = false;
  bool _isLoadingDates = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _fetchEmployeeGrade();
    await _fetchLocations();
  }

  Future<void> _fetchEmployeeGrade() async {
    try {
      final url = Uri.parse('https://webappsprd.tatapower.com/EmpMgrDetailsAPI/api/user/getempdetails_from_MSSQL_BasedonEmpNO?EmpNo=$currentEmpNo');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList = [];

        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map && decoded['data'] != null) {
          dataList = decoded['data'];
        }

        if (dataList.isNotEmpty) {
          if (mounted) {
            setState(() {
              _employeeGrade = dataList.first['SAP_CURR_GRADE_DESC_HDHOME'] ?? dataList.first['SAP_CURR_GRADE_DESC'] ?? "ME03";
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching employee grade: $e');
    }
  }

  Future<void> _fetchLocations() async {
    if (mounted) setState(() => _isLoadingLocations = true);

    try {
      final loc_model.LocationResponse locResponse = await _client.getLocations();

      if (locResponse.data != null && locResponse.data!.isNotEmpty) {
        var allLocations = locResponse.data!
            .where((loc) => loc.val != null && loc.val!.isNotEmpty && loc.key != null)
            .toList();

        List<loc_model.LocationData> eligibleLocations = [];
        List<Future<void>> validationFutures = [];

        for (var loc in allLocations) {
          final checkUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/search?model=chkhdhome&loccd=${loc.key}&grade=$_employeeGrade');

          validationFutures.add(
              http.get(checkUrl).then((response) {
                if (response.statusCode == 200) {
                  final decoded = jsonDecode(response.body);
                  if (decoded['success'] == true && decoded['data'] != null && (decoded['data'] as List).isNotEmpty) {
                    eligibleLocations.add(loc);
                  }
                }
              }).catchError((error) {
                debugPrint('Error validating location ${loc.val}: $error');
              })
          );
        }

        await Future.wait(validationFutures);

        var uniqueLocationsMap = <int, loc_model.LocationData>{};
        for (var loc in eligibleLocations) {
          uniqueLocationsMap[loc.key!] = loc;
        }

        if (mounted) {
          setState(() {
            _apiLocations = uniqueLocationsMap.values.toList();
            _isLoadingLocations = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingLocations = false);
      }
    } catch (e) {
      debugPrint("Error fetching/filtering locations: $e");
      if (mounted) setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _fetchHolidayHomes(int locationId) async {
    setState(() {
      _isLoadingHHs = true;
      _apiHolidayHomes = [];
      _selectedHHId = null;
      _propertyCardData = null;
      _apiSuites = [];
      _rawSuitesData = [];
      _selectedSuiteId = null;
      _bookedDates = [];
      _availabilityCalendar = [];
      _dateColorMap = {};
      _next30DaysDetails = [];
      _selectedDateRange = null;
    });

    try {
      final url = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/search?model=chkhdhome&loccd=$locationId&grade=$_employeeGrade');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final hhResponse = SelectHolidayHomeResponse.fromJson(decoded);

        if (mounted) {
          setState(() {
            if (hhResponse.success == true && hhResponse.data != null && hhResponse.data!.isNotEmpty) {
              var validHHs = hhResponse.data!.where((hh) {
                if (hh.hdHomeCd == null || hh.hdHomeCd! <= 0) return false;
                if (hh.hdHomeName == null || hh.hdHomeName!.trim().isEmpty) return false;
                if (hh.hdHomeName!.toLowerCase().contains('select')) return false;
                return true;
              }).map((hh) {
                return loc_model.LocationData(key: hh.hdHomeCd, val: hh.hdHomeName);
              }).toList();

              var uniqueHHMap = <int, loc_model.LocationData>{};
              for (var hh in validHHs) {
                uniqueHHMap[hh.key!] = hh;
              }
              _apiHolidayHomes = uniqueHHMap.values.toList();
            }
            _isLoadingHHs = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingHHs = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingHHs = false);
      debugPrint("Error fetching holiday homes: $e");
    }
  }

  Future<void> _fetchSuites(int hhId) async {
    setState(() {
      _isLoadingSuites = true;
      _apiSuites = [];
      _rawSuitesData = [];
      _selectedSuiteId = null;
      _bookedDates = [];
      _availabilityCalendar = [];
      _dateColorMap = {};
      _next30DaysDetails = [];
      _selectedDateRange = null;
      _maxAllowedDays = 30;
      _maxCapacity = 6;
    });

    try {
      final response = await _client.getSuitesByHolidayHome(hhId);
      if (mounted) {
        setState(() {
          if (response.data != null) {
            var validSuites = response.data!
                .where((suite) => suite.key != null && suite.key! > 0 && suite.val != null && !suite.val!.toLowerCase().contains('select'))
                .toList();

            var uniqueSuiteMap = <int, loc_model.LocationData>{};
            for (var suite in validSuites) {
              uniqueSuiteMap[suite.key!] = suite;
            }
            _apiSuites = uniqueSuiteMap.values.toList();
          }
          _isLoadingSuites = false;
        });
      }

      final url = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/dropdown?model=suitebasedonhdhome&hdhomeid=$hhId');
      final rawResponse = await http.get(url);
      if (rawResponse.statusCode == 200) {
        final decoded = jsonDecode(rawResponse.body);
        final suiteResponse = SuiteResponse.fromJson(decoded);
        if (suiteResponse.success == true && suiteResponse.data != null) {
          if (mounted) {
            setState(() {
              _rawSuitesData = suiteResponse.data!;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingSuites = false);
      debugPrint("Error fetching suites: $e");
    }
  }

  Future<void> _fetchSuiteAvailabilityData(int suiteId) async {
    setState(() {
      _isLoadingDates = true;
      _isLoadingAvailability = true;
      _selectedDateRange = null;
      _bookedDates = [];
      _availabilityCalendar = [];
      _dateColorMap = {}; // Reset the map
      _next30DaysDetails = [];
    });

    try {
      // 1. Fetch checkavail API for the Color Calendar Map
      try {
        final checkAvailUrl = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/hdhmbookingcheckavail?hdhomesuiteid=$suiteId');
        final checkAvailResponse = await http.get(checkAvailUrl);
        if (checkAvailResponse.statusCode == 200) {
          final decoded = jsonDecode(checkAvailResponse.body);
          final parsedData = HdmbookingcheckavailResponse.fromJson(decoded);

          if (parsedData.success == true && parsedData.data?.data != null) {
            _availabilityCalendar = parsedData.data!.data!;

            // --- BUILD THE BULLETPROOF STRING MAP ---
            for (var booking in _availabilityCalendar) {
              if (booking.hdHomeBookingFromdt != null && booking.hdHomeBookingTodt != null) {
                DateTime? from = _parseDate(booking.hdHomeBookingFromdt!);
                DateTime? to = _parseDate(booking.hdHomeBookingTodt!);

                if (from != null && to != null) {
                  // Determine color strictly by currwaiting count
                  String colorStatus = (booking.hdHomeBookingCurrwaiting != null && booking.hdHomeBookingCurrwaiting! > 0)
                      ? 'blue'
                      : 'red';

                  // Loop through dates from start (inclusive) to end (exclusive)
                  DateTime currentDay = DateTime(from.year, from.month, from.day);
                  DateTime endDay = DateTime(to.year, to.month, to.day);

                  while (currentDay.isBefore(endDay)) {
                    String dateKey = DateFormat('yyyy-MM-dd').format(currentDay);
                    // Blue (Waitlist) overwrites Red (Booked) if they overlap
                    if (_dateColorMap[dateKey] != 'blue') {
                      _dateColorMap[dateKey] = colorStatus;
                    }
                    currentDay = currentDay.add(const Duration(days: 1));
                  }

                  // Failsafe for identical from and to dates (same-day entry)
                  if (from.year == to.year && from.month == to.month && from.day == to.day) {
                    String dateKey = DateFormat('yyyy-MM-dd').format(currentDay);
                    if (_dateColorMap[dateKey] != 'blue') {
                      _dateColorMap[dateKey] = colorStatus;
                    }
                  }
                }
              }
            }
            debugPrint("MAP GENERATED: $_dateColorMap"); // Check your console to verify population!
          }
        }
      } catch (e) {
        debugPrint("Error fetching checkavail: $e");
      }

      // 2. Fetch Next 30 Days Details API (For the Detailed Table)
      try {
        final next30Url = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/hdhmbookingdetailsNext30days?hdhomesuiteid=$suiteId');
        final next30Response = await http.get(next30Url);
        if (next30Response.statusCode == 200) {
          final decoded = jsonDecode(next30Response.body);
          final parsedData = HdhmbookingdetailsNext30daysResponse.fromJson(decoded);
          if (parsedData.success == true && parsedData.data?.data != null) {
            _next30DaysDetails = parsedData.data!.data!;
          }
        }
      } catch (e) {
        debugPrint("Error fetching Next30Days: $e");
      }

      // 3. Derive legacy booked dates for UI blocking (Date Picker)
      List<DateTime> blockedDates = [];
      for (var item in _next30DaysDetails) {
        if (item.hdHomeBookingFromdt != null && item.hdHomeBookingTodt != null) {
          DateTime? fromDate = _parseDate(item.hdHomeBookingFromdt!);
          DateTime? toDate = _parseDate(item.hdHomeBookingTodt!);
          if (fromDate != null && toDate != null) {
            for (int i = 0; i <= toDate.difference(fromDate).inDays; i++) {
              blockedDates.add(fromDate.add(Duration(days: i)));
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _bookedDates = blockedDates;
          _isLoadingDates = false;
          _isLoadingAvailability = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDates = false;
          _isLoadingAvailability = false;
        });
      }
      debugPrint("Error fetching dates/availability: $e");
    }
  }

  DateTime? _parseDate(String dateStr) {
    String cleanStr = dateStr.trim();
    if (cleanStr.isEmpty) return null;

    try {
      return DateTime.parse(cleanStr);
    } catch (_) {}
    try {
      return DateFormat("dd/MM/yyyy").parse(cleanStr);
    } catch (_) {}
    try {
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(cleanStr);
    } catch (_) {}
    try {
      return DateFormat("yyyy-MM-dd").parse(cleanStr);
    } catch (_) {}
    return null;
  }

  Future<void> _pickDateRange() async {
    if (_selectedSuiteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a Suite first to see available dates.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.orange),
      );
      return;
    }

    final DateTime now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      bool containsBookedDate = false;
      int totalDaysSelected = picked.end.difference(picked.start).inDays;

      for (int i = 0; i <= totalDaysSelected; i++) {
        DateTime currentDay = picked.start.add(Duration(days: i));

        for (DateTime bookedDate in _bookedDates) {
          if (currentDay.year == bookedDate.year &&
              currentDay.month == bookedDate.month &&
              currentDay.day == bookedDate.day) {
            containsBookedDate = true;
            break;
          }
        }
        if (containsBookedDate) break;
      }

      if (containsBookedDate) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The selected range includes dates that are already booked. Please try a different range.', style: TextStyle(fontFamily: 'Inter')),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (totalDaysSelected > _maxAllowedDays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum booking duration for this suite is $_maxAllowedDays days.', style: const TextStyle(fontFamily: 'Inter')),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _onSearchPressed() async {
    if (_selectedLocationId == null || _selectedHHId == null || _selectedSuiteId == null || _selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all form parameters before searching.', style: TextStyle(fontFamily: 'Inter'))),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _propertyCardData = null;
    });

    try {
      final url = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/search?model=hddetails&locid=$_selectedLocationId');
      final uiResponse = await http.get(url);

      if (uiResponse.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(uiResponse.body);
        final detailsResponse = HdDetailsResponse.fromJson(responseData);

        if (detailsResponse.success == true && detailsResponse.data != null && detailsResponse.data!.isNotEmpty) {
          setState(() {
            _propertyCardData = detailsResponse.data!.first.toJson();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No property details found for this location.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.orange),
          );
        }
      }

      if (mounted) setState(() => _isSearching = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: $e', style: const TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildAvailabilityCalendar() {
    if (_selectedSuiteId == null) return const SizedBox.shrink();
    if (_isLoadingAvailability) return const Center(child: CircularProgressIndicator());

    final today = DateTime.now();
    List<DateTime> next30Days = List.generate(30, (index) => today.add(Duration(days: index)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Booked:', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 4),
            Container(width: 12, height: 24, color: Colors.redAccent.shade200),
            const SizedBox(width: 16),

            const Text('Available:', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 4),
            Container(width: 12, height: 24, color: Colors.lightGreen.shade300),
            const SizedBox(width: 16),

            const Text('WaitListed:', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(width: 4),
            Container(width: 12, height: 24, color: Colors.blue.shade800),
          ],
        ),
        const SizedBox(height: 16),

        Wrap(
          spacing: 2.0,
          runSpacing: 8.0,
          children: next30Days.map((date) {

            // Generate the exact String Key used in our map
            String gridDateKey = DateFormat('yyyy-MM-dd').format(date);

            // Pure string lookup: Extremely fast, extremely reliable
            String mappedColor = _dateColorMap[gridDateKey] ?? 'green';

            LinearGradient boxGradient;
            if (mappedColor == 'blue') {
              boxGradient = LinearGradient(colors: [Colors.blue.shade800, Colors.blue.shade700], begin: Alignment.topCenter, end: Alignment.bottomCenter);
            } else if (mappedColor == 'red') {
              boxGradient = LinearGradient(colors: [Colors.red.shade400, Colors.redAccent.shade200], begin: Alignment.topCenter, end: Alignment.bottomCenter);
            } else {
              boxGradient = LinearGradient(colors: [Colors.lightGreen.shade400, Colors.lightGreen.shade300], begin: Alignment.topCenter, end: Alignment.bottomCenter);
            }

            return SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(DateFormat('dd MMM').format(date), style: const TextStyle(fontSize: 10, fontFamily: 'Inter')),
                  const SizedBox(height: 2),
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        gradient: boxGradient,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 1)
                        ]
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingDetailsTable() {
    if (_selectedSuiteId == null || _next30DaysDetails.isEmpty) return const SizedBox.shrink();
    if (_isLoadingAvailability) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text("Booking Details (Next 30 Days)", style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4)
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.white),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                }
                return Colors.grey.shade100;
              }),
              columns: const [
                DataColumn(label: Text('Booking Id', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
                DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
                DataColumn(label: Text('Employee Number', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
                DataColumn(label: Text('Booking From Date', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
                DataColumn(label: Text('Booking To Date', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
                DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
                DataColumn(label: Text('Current Status', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)))),
              ],
              rows: _next30DaysDetails.map((detail) {
                String fromDisplay = detail.hdHomeBookingFromdt ?? '';
                String toDisplay = detail.hdHomeBookingTodt ?? '';

                DateTime? parsedFrom = _parseDate(fromDisplay);
                DateTime? parsedTo = _parseDate(toDisplay);

                if (parsedFrom != null) fromDisplay = DateFormat('dd/MM/yyyy').format(parsedFrom);
                if (parsedTo != null) toDisplay = DateFormat('dd/MM/yyyy').format(parsedTo);

                return DataRow(
                    cells: [
                      DataCell(Text(detail.hdHmTransSno?.toString() ?? '-')),
                      DataCell(Text(detail.hdHomeBookingEmpname ?? '-')),
                      DataCell(Text(detail.hdHomeBookingEmpno?.toString() ?? '-')),
                      DataCell(Text(fromDisplay)),
                      DataCell(Text(toDisplay)),
                      DataCell(Text((detail.bookingStatus ?? '-').trim())),
                      DataCell(Text(detail.hdHomeBookingStatusCd?.toString() ?? detail.currentWaitingno ?? '-')),
                    ]
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String addressStr = 'Address not available';
    if (_propertyCardData != null) {
      final add1 = _propertyCardData!['hdHomeAddress1']?.toString().trim() ?? '';
      final add2 = _propertyCardData!['hdHomeAddress2']?.toString().trim() ?? '';
      if (add1.isNotEmpty && add2.isNotEmpty) {
        addressStr = '$add1\n$add2';
      } else if (add1.isNotEmpty) {
        addressStr = add1;
      } else if (add2.isNotEmpty) {
        addressStr = add2;
      }
    }

    String imageUrl =
        'assets/images/places/${(_selectedLocationName == "Shirawata") ? "Sherowta" : (_selectedLocationName ?? "default")}.jpg';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Self Booking',
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
            _isLoadingLocations
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
              style: const TextStyle(fontFamily: 'Inter', color: Colors.black87, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Select Location', labelStyle: TextStyle(fontFamily: 'Inter'), border: OutlineInputBorder()),
              value: _selectedLocationId,
              items: _apiLocations.isEmpty ? null : _apiLocations.map((loc) {
                return DropdownMenuItem<int>(value: loc.key, child: Text(loc.val!));
              }).toList(),
              onChanged: (val) {
                if (val != null && val != _selectedLocationId) {
                  final selectedLoc = _apiLocations.firstWhere((element) => element.key == val);
                  setState(() {
                    _selectedLocationId = val;
                    _selectedLocationName = selectedLoc.val;
                  });
                  _fetchHolidayHomes(val);
                }
              },
            ),
            const SizedBox(height: 20),

            _isLoadingHHs
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
              style: const TextStyle(fontFamily: 'Inter', color: Colors.black87, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Select Holiday Home', labelStyle: TextStyle(fontFamily: 'Inter'), border: OutlineInputBorder()),
              value: _selectedHHId,
              items: (_selectedLocationId == null || _apiHolidayHomes.isEmpty) ? null : _apiHolidayHomes.map((hh) {
                return DropdownMenuItem<int>(value: hh.key, child: Text(hh.val!));
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedHHId = val);
                if (val != null) {
                  _fetchSuites(val);
                }
              },
            ),
            const SizedBox(height: 20),

            _isLoadingSuites
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<int>(
              style: const TextStyle(fontFamily: 'Inter', color: Colors.black87, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Select Suite', labelStyle: TextStyle(fontFamily: 'Inter'), border: OutlineInputBorder()),
              value: _selectedSuiteId,
              items: (_selectedHHId == null || _apiSuites.isEmpty) ? null : _apiSuites.map((suite) {
                return DropdownMenuItem<int>(value: suite.key, child: Text(suite.val!));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedSuiteId = val;
                  if (val != null) {
                    try {
                      final selectedSuite = _rawSuitesData.firstWhere((s) => s.hdHomeSuiteCd == val);
                      int days = 30;
                      if (selectedSuite.hdHomeMaxdayallow != null && selectedSuite.hdHomeMaxdayallow!.isNotEmpty) {
                        days = int.tryParse(selectedSuite.hdHomeMaxdayallow!) ?? selectedSuite.hdHomeSuiteMaxdays ?? 30;
                      } else if (selectedSuite.hdHomeSuiteMaxdays != null) {
                        days = selectedSuite.hdHomeSuiteMaxdays!;
                      }
                      _maxAllowedDays = days;
                      _maxCapacity = selectedSuite.hdHomeSuiteMaxcap ?? 6;
                    } catch (e) {
                      debugPrint("Could not extract suite details: $e");
                    }
                  }
                });

                if (val != null) {
                  _fetchSuiteAvailabilityData(val);
                }
              },
            ),
            const SizedBox(height: 20),

            _buildAvailabilityCalendar(),
            const SizedBox(height: 20),

            InkWell(
              onTap: _isLoadingDates ? null : _pickDateRange,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Select Dates (From - To)',
                  labelStyle: TextStyle(fontFamily: 'Inter'),
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _isLoadingDates
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                      _selectedDateRange == null
                          ? 'Choose dates'
                          : '${DateFormat('dd MMM yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(_selectedDateRange!.end)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: _selectedDateRange == null ? Colors.grey.shade600 : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: (_isSearching || _isLoadingLocations || _isLoadingHHs || _isLoadingSuites || _isLoadingDates)
                  ? null
                  : _onSearchPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSearching
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Search', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            _buildBookingDetailsTable(),

            if (_propertyCardData != null) ...[
              const SizedBox(height: 40),
              Text(
                'Holiday Homes: ${_selectedLocationName ?? 'Result'}',
                style: const TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color.fromRGBO(0, 100, 200, 0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 180,
                                color: Colors.grey.shade100,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _propertyCardData!['hdHomeName']?.toString() ?? 'Property Name',
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(0, 100, 200, 1.0)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        addressStr,
                        style: TextStyle(fontFamily: 'Inter', color: Colors.blue.shade700, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            Container(
                              color: const Color.fromRGBO(0, 100, 200, 1.0),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              child: Row(
                                children: const [
                                  Expanded(child: Text('Care Taker Name', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                                  Expanded(child: Text('Care Taker Email', style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              child: Row(
                                children: [
                                  Expanded(child: Text(_propertyCardData!['hdhomeContactPersonName']?.toString() ?? 'Not Available', style: const TextStyle(fontFamily: 'Inter', color: Colors.black87, fontSize: 13))),
                                  Expanded(child: Text(_propertyCardData!['hdhomeContactPersonEmail']?.toString() ?? 'Not Available', style: const TextStyle(fontFamily: 'Inter', color: Colors.black87, fontSize: 13))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(children: List.generate(5, (index) => const Icon(Icons.star, color: Color.fromRGBO(0, 100, 200, 1.0), size: 22))),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_propertyCardData != null && _selectedSuiteId != null && _selectedDateRange != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PropertySelfDetailsScreen(
                                          propertyData: _propertyCardData!,
                                          suiteId: _selectedSuiteId!,
                                          fromDate: _selectedDateRange!.start,
                                          toDate: _selectedDateRange!.end,
                                          maxCapacity: _maxCapacity,
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please ensure Suite and Dates are selected.', style: TextStyle(fontFamily: 'Inter')),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: const Text('View Details', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Advance Booking Before $_maxAllowedDays Days',
                                style: TextStyle(fontFamily: 'roboto', fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}