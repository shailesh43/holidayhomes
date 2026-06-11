import 'package:flutter/material.dart';
import 'package:holidayhomes/custom/modals/bookings_details_modal.dart';
import 'package:holidayhomes/custom/widgets/bookings_card.dart';
import 'package:holidayhomes/network/api_models/booking.dart';
import '../widgets/custom_search_bar.dart';
import '../../core/utils/enum.dart';
import '../../network/api_client.dart';
class SearchScreen extends StatefulWidget {
  final UserRole role;

  SearchScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final ApiClient _client = ApiClient();
  bool isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String selectedFilter = 'Active';
  final List<Booking> activeRequests = [];
  final List<Booking> inactiveRequests = [];

  @override
  void initState() {
    super.initState();
    _loadFilterBasedRequests();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<void> _loadFilterBasedRequests() async {
    setState(() {
      isLoading = true;
    });

    // 1️⃣ Get the From and To date

    // if (empId == null || empId.isEmpty) {
    //   debugPrint('Employee ID is null or empty');
    //   setState(() => isLoading = false);
    //   return;
    // }

    try {
      // 2️⃣ API call (NEW endpoint)
      final response = await _client.getStatusFilteredRequests(
        fromDate: '2026-01-12T00:00:00.000Z',
        toDate: '2026-07-03T23:59:59.000Z',
      );

      // 3️⃣ Update state
    } catch (e) {
      debugPrint('Error fetching status-filtered requests: $e');
      setState(() => isLoading = false);
    }
  }


  void _showDeleteRequestModal(BuildContext context, Booking request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingsDetailsModal(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {

    final List<Booking> baseList =
    selectedFilter == 'Active'
        ? activeRequests
        : inactiveRequests;

    final List<Booking> filteredRequests =
    _searchQuery.isEmpty
        ? baseList
        : baseList.where((request) {
      final name = request.hdHomeBookByEmpName?.toLowerCase() ?? '';
      return name.contains(_searchQuery);
    }).toList();


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
          'Search',
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // 🔍 Search Bar
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search by employee name',
                ),
                const SizedBox(height: 8),

                // 🔘 Filter Buttons
                Row(
                  children: [
                    _buildFilterButton(
                      label: 'Active',
                      isSelected: selectedFilter == 'Active',
                      activeColor: const Color.fromRGBO(215, 255, 216, 1.0),
                      activeTextColor: const Color.fromRGBO(23, 86, 26, 1.0),
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Active';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterButton(
                      label: 'Inactive',
                      isSelected: selectedFilter == 'Inactive',
                      activeColor: const Color.fromRGBO(255, 227, 227, 1.0),
                      activeTextColor: const Color.fromRGBO(86, 23, 23, 1.0),
                      onTap: () {
                        setState(() {
                          selectedFilter = 'Inactive';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 📜 Requests List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder:
                  (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.05),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: filteredRequests.isEmpty
                  ? Center(
                key: ValueKey<String>('empty_$selectedFilter'),
                child: const Text(
                  'No Such Requests',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
                  : ListView.builder(
                key: ValueKey<String>(selectedFilter),
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredRequests.length,
                itemBuilder: (context, index) {
                  final request = filteredRequests[index];
                  return BookingsCard(
                    booking: request,
                    onTap: () {
                      _showDeleteRequestModal(context, request);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = Colors.black,
    Color activeTextColor = Colors.white,
    Color inactiveColor = const Color.fromRGBO(255, 255, 255, 1.0),
    Color inactiveTextColor = Colors.black45,
    EdgeInsetsGeometry padding =
    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    double borderRadius = 20,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: isSelected ? activeColor : Color.fromRGBO(
              227, 227, 227, 1.0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isSelected ? activeTextColor : inactiveTextColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

}