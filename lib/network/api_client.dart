import 'dart:async';
import 'dart:convert';
import 'dart:io'; // 🛠️ Required for HttpClient and X509Certificate
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// REFERENCES
import '../../core/constants/api_constants.dart';
import 'package:holidayhomes/network/api_models/booking_id_response.dart';
import 'package:holidayhomes/network/api_models/all_bookings_response.dart';
import 'package:holidayhomes/network/api_models/guest_info_response.dart';
import 'package:holidayhomes/network/api_models/edit_guest_info_response.dart';
import 'package:holidayhomes/network/api_models/base_api_response.dart';
import 'package:holidayhomes/network/api_models/location_response.dart' as loc_model;
import 'package:holidayhomes/network/api_models/employee_response.dart' as emp_model;
import 'package:holidayhomes/network/api_models/hddetails_response.dart';
import 'package:holidayhomes/network/api_models/booking_data_response.dart';
import 'package:holidayhomes/network/api_models/select_holiday_home.dart' as hh_model;
import 'package:holidayhomes/network/api_models/suite_response.dart' as suite_model;

// 🛠️ ADDED: Import for Availability Check
import 'package:holidayhomes/network/api_models/hdmbookingcheckavail_response.dart';

// Imports for BookingsPage tabs
import 'package:holidayhomes/network/api_models/my_bookings_response.dart';
import 'package:holidayhomes/network/api_models/facilitator_booking_response.dart';

// Imports for Cancellation flow
import 'package:holidayhomes/network/api_models/status_message_response.dart';
import 'package:holidayhomes/network/api_models/booking_result_response.dart';

// 🛠️ ADDED: Import for 30 Days API
import 'package:holidayhomes/network/api_models/hdhmbookingdetailsNext30days_response.dart';

class ApiClient {
  static http.Client? _pinnedClient;

  http.Client get _client {
    if (_pinnedClient != null) {
      return _pinnedClient!;
    }

    final HttpClient httpClient = HttpClient()
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    return IOClient(httpClient);
  }

  Future<Map<String, String>> _defaultHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (Android; Mobile) AppleWebKit/537.36',
    };
  }

  dynamic _handleResponse(http.Response response, String method) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('API Error [${response.statusCode}]: ${response.body}');
  }

  Future<FilteredBookingsResponse> getStatusFilteredRequests({required String fromDate, required String toDate}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('fetchReportSubmit');
    final response = await _client.post(
        Uri.parse(endpointUrl),
        headers: await _defaultHeaders(),
        body: jsonEncode({'hdHomeBookingFromdt': fromDate, 'hdHomeBookingTodt': toDate})
    );
    return FilteredBookingsResponse.fromJson(_handleResponse(response, 'POST'));
  }

  Future<GuestInfoResponse> getGuestsInfo({required String bookingId}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('searchModel');
    final response = await _client.get(
        Uri.parse('$endpointUrl?model=mybookinginfo&transno=$bookingId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));
    return GuestInfoResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<EditGuestInfoResponse> getEditGuestInfo({required String bookingId}) async {
    final response = await _client.get(
        Uri.parse('${ApiConstants.baseURL}/hdhm/guests/$bookingId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));
    return EditGuestInfoResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<loc_model.LocationResponse> getLocations() async {
    final endpointUrl = await ApiConstants.getEndPointUrl('fetchLocations');
    final response = await _client.get(Uri.parse(endpointUrl));
    final data = _handleResponse(response, 'GET');
    if (data is List) {
      return loc_model.LocationResponse(
          success: true,
          data: data.map((v) => loc_model.LocationData.fromJson(v)).toList()
      );
    }
    return loc_model.LocationResponse.fromJson(data);
  }

  Future<loc_model.LocationResponse> getHolidayHomesByLocation(int locationId) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('holidayHomeMaster');
    final response = await _client.get(
        Uri.parse(endpointUrl),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));

    final hhResponse = hh_model.SelectHolidayHomeResponse.fromJson(_handleResponse(response, 'GET'));
    if (hhResponse.data != null) {
      return loc_model.LocationResponse(
          success: true,
          data: hhResponse.data!.map((e) => loc_model.LocationData(key: e.hdHomeCd, val: e.hdHomeName)).toList()
      );
    }
    return loc_model.LocationResponse(success: false, data: []);
  }

  Future<loc_model.LocationResponse> getSuitesByHolidayHome(int hhId) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('dropdownModel');
    final response = await _client.get(
        Uri.parse('$endpointUrl?model=suitebasedonhdhome&hdhomeid=$hhId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));

    final suiteResponse = suite_model.SuiteResponse.fromJson(_handleResponse(response, 'GET'));
    if (suiteResponse.data != null) {
      return loc_model.LocationResponse(
          success: true,
          data: suiteResponse.data!.map((e) => loc_model.LocationData(key: e.hdHomeSuiteCd, val: e.hdHomeSuiteName)).toList()
      );
    }
    return loc_model.LocationResponse(success: false, data: []);
  }

  Future<HdDetailsResponse> getHolidayHomeDetails({required int hhId}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('fetchPropertyDetails');
    final response = await _client.get(
        Uri.parse('$endpointUrl?hdHomeCd=$hhId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));
    return HdDetailsResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<emp_model.EmployeeResponse> verifyEmployee({required String empId}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('fetchEmployee');
    final response = await _client.get(
        Uri.parse('$endpointUrl?EmpNo=$empId'),
        headers: await _defaultHeaders()
    );
    return emp_model.EmployeeResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<BookingDataResponse> findBookingById({required String bookingId}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('searchModel');
    final response = await _client.get(
        Uri.parse('$endpointUrl?model=findbooking&bookingId=$bookingId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));

    final responseData = jsonDecode(response.body);
    if (responseData['success'] == true) {
      if (responseData['data'] is Map) {
        return BookingDataResponse(
            success: true,
            data: [BookingData.fromJson(responseData['data'])]
        );
      }
      return BookingDataResponse.fromJson(responseData);
    }
    throw Exception('API returned success: false');
  }

  Future<BookingDataResponse> submitCancelBooking({required String bookingId}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('cancelBooking');
    final response = await _client.get(
        Uri.parse('$endpointUrl&bookingId=$bookingId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));
    return BookingDataResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<bool> saveGuestDetails({required String bookingId, required List<Map<String, dynamic>> guests}) async {
    final response = await _client.post(
        Uri.parse('${ApiConstants.baseURL}/hdhm/guests/update'),
        headers: await _defaultHeaders(),
        body: jsonEncode({'bookingId': bookingId, 'guests': guests})
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode >= 200 && response.statusCode < 300) return true;
    throw Exception('Server returned ${response.statusCode}');
  }

  Future<MyBookingsResponse> getMyBookings({required String empNo}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('searchModel');
    final response = await _client.get(
        Uri.parse('$endpointUrl?model=mybooking&empno=$empNo'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 10));
    return MyBookingsResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<FacilitatorBookingResponse> getFacilitatorBookings({required String empNo}) async {
    final endpointUrl = await ApiConstants.getEndPointUrl('searchModel');
    final response = await _client.get(
        Uri.parse('$endpointUrl?model=mybookingother&empno=$empNo'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 10));
    return FacilitatorBookingResponse.fromJson(_handleResponse(response, 'GET'));
  }

  Future<StatusMessageResponse> sendCancellationMail({required String bookingId, required String reason}) async {
    final response = await _client.post(
        Uri.parse('${ApiConstants.baseURL}/sendMail'),
        headers: await _defaultHeaders(),
        body: jsonEncode({'bookingId': bookingId, 'reason': reason})
    ).timeout(const Duration(seconds: 30));
    return StatusMessageResponse.fromJson(_handleResponse(response, 'POST'));
  }

  Future<BookingResultResponse> submitCancelBookingWithReason({required String bookingId, required String reason}) async {
    final response = await _client.post(
        Uri.parse('${ApiConstants.baseURL}/hdhmbookingcancel'),
        headers: await _defaultHeaders(),
        body: jsonEncode({'bookingId': bookingId, 'reason': reason})
    ).timeout(const Duration(seconds: 30));
    return BookingResultResponse.fromJson(_handleResponse(response, 'POST'));
  }

  Future<Map<String, dynamic>?> getPropertyCardDetailsByLocId(int locId) async {
    final response = await _client.get(
        Uri.parse('${ApiConstants.baseURL}/master/search?model=hddetails&locid=$locId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));

    final data = _handleResponse(response, 'GET');
    if (data['success'] == true && data['data'] != null) {
      List dataList = data['data'] is List ? data['data'] : [data['data']];
      if (dataList.isNotEmpty) return dataList.first as Map<String, dynamic>;
    }
    return null;
  }

  Future<HdhmbookingdetailsNext30daysResponse> getBookingRulesNext30Days(int hhId) async {
    final response = await _client.get(
        Uri.parse('${ApiConstants.baseURL}/master/search?model=hdhmbookingdetailsNext30days&hdhomeid=$hhId'),
        headers: await _defaultHeaders()
    ).timeout(const Duration(seconds: 30));
    return HdhmbookingdetailsNext30daysResponse.fromJson(_handleResponse(response, 'GET'));
  }

  // ── 🛠️ FIXED: Proper GET Request to Fetch Booked Dates! ──
  Future<HdmbookingcheckavailResponse> getBookedDatesForSuite(int suiteId) async {
    final url = Uri.parse('${ApiConstants.baseURL}/master/search?model=hdhmbookingcheckavail&suiteid=$suiteId');
    print('🚀 FETCHING BOOKED DATES: $url');
    try {
      final response = await _client.get(
          url,
          headers: await _defaultHeaders()
      ).timeout(const Duration(seconds: 30));
      return HdmbookingcheckavailResponse.fromJson(_handleResponse(response, 'GET'));
    } catch (e) {
      throw Exception('Failed to fetch availability: $e');
    }
  }
}