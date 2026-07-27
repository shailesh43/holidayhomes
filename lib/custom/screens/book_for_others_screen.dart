import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:holidayhomes/network/api_client.dart';
import 'package:holidayhomes/main.dart';

import 'package:holidayhomes/network/api_models/location_response.dart' as loc_model;
import 'package:holidayhomes/network/api_models/employee_response.dart' as emp_model;
import 'package:holidayhomes/network/api_models/hddetails_response.dart';
import 'package:holidayhomes/network/api_models/base_api_response.dart';
import 'package:holidayhomes/network/api_models/hdhmbookingdetailsNext30days_response.dart';
import 'package:holidayhomes/network/api_models/hdmbookingcheckavail_response.dart';
import 'package:holidayhomes/network/api_models/select_holiday_home_response.dart';
import 'package:holidayhomes/network/api_models/suite_response.dart';

import 'property_others_details_screen.dart';

class BookForOthersScreen extends StatefulWidget {
  const BookForOthersScreen({super.key});

  @override
  State<BookForOthersScreen> createState() => _BookForOthersScreenState();
}

class _BookForOthersScreenState extends State<BookForOthersScreen> {
  final ApiClient _client = globalApiClient;
  final TextEditingController _employeeIdController = TextEditingController();

  bool _isCheckingEmpId = false;
  bool _hasError = false;
  String? _verifiedEmpName;

  // 🚀 To store the grade dynamically from the entered ID
  String? _employeeGrade;

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

  Map<String, dynamic>? _propertyCardData;

  int _maxAllowedDays = 30;
  int _maxCapacity = 6;

  bool _isLoadingLocations = false;
  bool _isLoadingHHs = false;
  bool _isLoadingSuites = false;
  bool _isLoadingDates = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    super.dispose();
  }

  Future<void> _checkEmployeeId() async {
    final enteredId = _employeeIdController.text.trim();
    if (enteredId.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isCheckingEmpId = true;
      _hasError = false;
      _verifiedEmpName = null;
      _employeeGrade = null;
      _selectedLocationId = null;
      _selectedHHId = null;
      _selectedSuiteId = null;
      _selectedDateRange = null;
      _propertyCardData = null;
      _apiLocations = [];
    });

    try {
      final emp_model.EmployeeResponse response = await _client.verifyEmployee(empId: enteredId);
      if (mounted) {
        if (response.data != null && response.data!.isNotEmpty) {
          final emp = response.data!.first;
          setState(() {
            _verifiedEmpName = emp.sAPDISPNAME ?? emp.sAPSHORTNAME ?? 'Unknown Employee';
            // 🚀 Extract the specific grade, with robust fallbacks
            _employeeGrade = emp.sAPCURRGRADEDESCHDHOME ?? emp.sAPCURRGRADEDESC ?? "ME03";
            _isCheckingEmpId = false;
          });

          // 🚀 Employee is verified! Now fetch ONLY the locations they are allowed to see
          await _fetchLocations();
        } else {
          setState(() {
            _hasError = true;
            _isCheckingEmpId = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isCheckingEmpId = false;
        });
      }
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
      _selectedDateRange = null;
    });

    final gradeToUse = _employeeGrade ?? "ME03";

    try {
      final url = Uri.parse('https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/master/search?model=chkhdhome&loccd=$locationId&grade=$gradeToUse');
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

            if (_apiHolidayHomes.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No eligible Holiday Homes available for this location and grade.', style: TextStyle(fontFamily: 'Inter')), backgroundColor: Colors.orange),
              );
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

  Future<void> _fetchBookedDatesForSuite(int suiteId) async {
    setState(() {
      _isLoadingDates = true;
      _selectedDateRange = null;
      _bookedDates = [];
    });

    try {
      final availabilityData = await _client.getBookedDatesForSuite(suiteId);
      List<DateTime> blockedDates = [];

      if (availabilityData.success == true && availabilityData.data?.data != null) {
        for (var item in availabilityData.data!.data!) {
          if (item.hdHomeBookingFromdt != null && item.hdHomeBookingTodt != null) {
            try {
              DateTime? fromDate = _parseDate(item.hdHomeBookingFromdt!);
              DateTime? toDate = _parseDate(item.hdHomeBookingTodt!);

              if (fromDate != null && toDate != null) {
                for (int i = 0; i <= toDate.difference(fromDate).inDays; i++) {
                  blockedDates.add(fromDate.add(Duration(days: i)));
                }
              }
            } catch (parseError) {
              debugPrint("Date Parsing Error: $parseError");
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _bookedDates = blockedDates;
          _isLoadingDates = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDates = false);
      debugPrint("Error fetching dates: $e");
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'").parse(dateStr);
    } catch (_) {}
    try {
      return DateTime.parse(dateStr);
    } catch (_) {}
    try {
      return DateFormat("yyyy-MM-dd").parse(dateStr);
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

  @override
  Widget build(BuildContext context) {
    final bool isVerified = _verifiedEmpName != null;

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
        title: const Text('Book For Others',
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
            // ── Verify Employee Field ──
            TextField(
              controller: _employeeIdController,
              style: const TextStyle(fontFamily: 'Inter'),
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                labelStyle: TextStyle(fontFamily: 'Inter'),
                hintText: 'Enter Employee ID',
                hintStyle: TextStyle(fontFamily: 'Inter'),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromRGBO(0, 100, 200, 0.85), width: 1.5)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              enabled: !_isCheckingEmpId,
            ),
            const SizedBox(height: 8),

            if (_hasError)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('Network/Server Error or Employee not found!', style: TextStyle(fontFamily: 'Inter', color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            if (isVerified)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text('Employee: $_verifiedEmpName', style: const TextStyle(fontFamily: 'Inter', color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
              ),

            if (!isVerified)
              ElevatedButton(
                onPressed: _isCheckingEmpId ? null : _checkEmployeeId,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 100, 200, 0.85),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isCheckingEmpId
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Check', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
              ),

            // ── Show Form ONLY after Employee is Verified ──
            if (isVerified) ...[
              const Divider(height: 40, thickness: 1, color: Color.fromRGBO(0, 100, 200, 0.2)),

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
                    _fetchBookedDatesForSuite(val);
                  }
                },
              ),
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
                    : const Text('Search Availability', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold)),
              ),

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
                                          builder: (context) => PropertyOthersDetailsScreen(
                                            propertyData: _propertyCardData!,
                                            suiteId: _selectedSuiteId!,
                                            fromDate: _selectedDateRange!.start,
                                            toDate: _selectedDateRange!.end,
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
          ],
        ),
      ),
    );
  }
}