import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {

  // BASEURL of Holiday Homes node backend
  // static String baseURl = "http://localhost:3010/api/";

  // BASEURL of Holiday Homes Development backend
  static String baseURl = "https://bizappsd.tatapower.com/dev/api/holiday-homes/hdhomes/api/";
  static String serverURL = "https://bizapps.tatapower.com";
  static String get shaFingerPrint => dotenv.env['SHA_FINGERPRINT'] ?? '';

  // MS-SAMAL auth credentials & URL params
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
  static const String selfBooking = 'adminSelfBooking/';
  static const String master = 'master/';
  static const String search = 'search/';
  static const String dropdown = 'dropdown/';


  // getX function for getting the "API endpoint url"
  static Future<String> getEndPointUrl(String endPointName) async {
    String endPointUrl = "";
    switch (endPointName) {
      case "searchLocation":
        endPointUrl = "$baseURl$master$search";
      case "searchDropDown":
        endPointUrl = "$baseURl$master$dropdown";
        break;
    }
    return endPointUrl;
  }
}




