import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:holidayhomes/custom/modals/bookings_details_modal.dart';
import 'package:holidayhomes/custom/widgets/bookings_card.dart';
import 'package:holidayhomes/network/api_models/booking.dart';
import '../widgets/custom_search_bar.dart';
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';

class SearchScreen extends StatefulWidget {
  final UserRole role;

  const SearchScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiClient _client = ApiClient();
  bool isLoading = false;
  bool _hasSearched = false;
  final Logger logger = Logger();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  DateTimeRange? _selectedDateRange;
  List<Booking> _allBookings = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(start: now, end: now);

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  // ── Date range picker ────────────────────────────────────────────────────
  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(0, 100, 200, 0.85),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    return '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  String get _dateRangeLabel {
    if (_selectedDateRange == null) return 'Select Date Range';
    return '${_formatDate(_selectedDateRange!.start)}'
        ' - '
        '${_formatDate(_selectedDateRange!.end)}';
  }

  // Formats to the required API shape:
  // from → "2025-12-04T00:00:00.000Z"
  // to   → "2026-06-12T23:59:59.000Z"
  String _toFromDate(DateTime dt) {
    final d = DateTime.utc(dt.year, dt.month, dt.day, 0, 0, 0, 0);
    return d.toIso8601String().replaceFirst(RegExp(r'\.000$'), '.000Z');
  }

  String _toToDate(DateTime dt) {
    final d = DateTime.utc(dt.year, dt.month, dt.day, 23, 59, 59, 0);
    return '${dt.year.toString().padLeft(4, '0')}'
        '-${dt.month.toString().padLeft(2, '0')}'
        '-${dt.day.toString().padLeft(2, '0')}'
        'T23:59:59.000Z';
  }

  // ── API call ─────────────────────────────────────────────────────────────
  Future<void> _submitDateRange() async {
    if (_selectedDateRange == null) return;
    setState(() {
      isLoading = true;
      _hasSearched = true;
    });

    final from = _toFromDate(_selectedDateRange!.start);
    final to = _toToDate(_selectedDateRange!.end);

    debugPrint('Fetching bookings: {hdHomeBookingFromdt: "$from", hdHomeBookingTodt: "$to"}');

    try {
      final response = await _client.getStatusFilteredRequests(
        fromDate: from,
        toDate: to,
      );

      debugPrint("Bookings count = ${response.data.data.length}");

      setState(() {
        _allBookings = response.data.data;
        isLoading = false;
      });

    } catch (e, st) {
      debugPrint("ERROR: $e");
      debugPrint("STACK: $st");
    }
  }

  // ── Search filter ─────────────────────────────────────────────────────────
  List<Booking> get _filteredBookings {
    if (_searchQuery.isEmpty) return _allBookings;
    return _allBookings.where((b) {
      final name = b.hdHomeBookByEmpName?.toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();
  }

  // ── Modal ─────────────────────────────────────────────────────────────────
  void _openDetailsModal(BuildContext context, Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingsDetailsModal(request: booking),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search Bookings',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search Bar ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: CustomSearchBar(
              controller: _searchController,
              hintText: 'Search by employee name',
            ),
          ),

          // ── Date Range + Submit ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(0, 100, 200, 0.6),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: Color.fromRGBO(0, 100, 200, 0.8),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dateRangeLabel,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(0, 100, 200, 0.85),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _submitDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 100, 200, 0.85),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bookings List ────────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasSearched
                ? const Center(
              child: Text(
                'Select a date range and press Submit',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
                : bookings.isEmpty
                ? const Center(
              child: Text(
                'No bookings found',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
                : RefreshIndicator(
              onRefresh: _submitDateRange,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingsCard(
                    booking: booking,
                    onTap: () => _openDetailsModal(context, booking),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}