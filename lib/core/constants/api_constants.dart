  import 'dart:io';
  import 'package:flutter_dotenv/flutter_dotenv.dart';

  class ApiConstants {

    static String baseURL = "https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api";
    static String serverURL = "https://bizappsd.tatapower.com";

    static String empDetailsURL = "https://webappsprd.tatapower.com/EmpMgrDetailsAPI/api/user/getempdetails_from_MSSQL_BasedonEmpNO";
    static String empProfileURL = "https://webappsprd.tatapower.com/Employeephotos";

    static String get shaFingerPrint => dotenv.env['SHA_FINGERPRINT'] ?? '';

    static String get tenantId => dotenv.env['TENANT_ID'] ?? '';
    static String get clientId => dotenv.env['CLIENT_ID'] ?? '';
    static String get redirectUri {
      if (Platform.isIOS) {
        return dotenv.env['REDIRECT_URI_IOS']!;
      } else {
        return dotenv.env['REDIRECT_URI_ANDROID']!;
      }
    }
    static String get scope => dotenv.env['SCOPE'] ?? 'User.Read offline_access';
    static String get userGraphUrl => dotenv.env['USER_GRAPH_URL'] ?? 'https://graph.microsoft.com/beta/me';
    static String get authorizationEndpoint =>
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';
    static String get tokenEndpoint =>
        'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

    // Holiday Homes Endpoints

    // Master Routes
    static const String master = '/master';
    static const String search = '/search';
    static const String dropdown = '/dropdown';
    static const String save = '/save';

    // Standalone Routes for details
    static const String locationMaster = '/LocationMaster';
    static const String hdHomeMaster = '/hdhmmaster';
    static const String hdHomeSuiteMaster = '/hdhmsuitemaster';

    // Action Buttons
    static const String fetchReportSubmit = "/PayRollData";
    static const String holidayHomeMaster = "/hdhmmaster";

    // getX function for getting the "API endpoint url"
    static Future<String> getEndPointUrl(String endPointName) async {
      String endPointUrl = "";
      switch (endPointName) {
        case "searchModel":
          endPointUrl = "$baseURL$master$search";
          break;
        case "dropdownModel":
          endPointUrl = "$baseURL$master$dropdown"; // 👈 This will now use the correct dev URL!
          break;
        case "fetchReportSubmit":
          endPointUrl = "$baseURL$fetchReportSubmit";
          break;
        case "holidayHomeMaster":
          endPointUrl = "$baseURL$holidayHomeMaster";
          break;
        case "fetchLocations":
          endPointUrl = "$baseURL$master$dropdown?model=location";
          break;
        case "fetchEmployee":
          endPointUrl = empDetailsURL;
          break;
      // ── 🛠️ FIXED: Added the endpoints for Print Intimation! ──
        case "fetchBookingById":
          endPointUrl = "$baseURL/fetchBookingById";
          break;
        case "fetchGuestsInfo":
          endPointUrl = "$baseURL/fetchGuestsInfo";
          break;
      // ── 🛠️ ADDED: Make sure property details route exists for your search button! ──
        case "fetchPropertyDetails":
          endPointUrl = "$baseURL/propertydetails"; // Update if your backend path is different
          break;
      // ── 🛠️ ADDED: Endpoint for Cancel Booking! ──
        case "cancelBooking":
          endPointUrl = "$baseURL/cancelbooking"; // Update if your backend path is different
          break;
      }
      return endPointUrl;
    }
  }