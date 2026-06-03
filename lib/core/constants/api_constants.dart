import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {

  // BASEURL of Holiday Homes node backend
  // static String baseURl = "http://localhost:3010/api/";

  // BASEURL of Holiday Homes Production backend
  static String baseURl = "https://bizapps.tatapower.com/api/greengears/carmanagement/api/";
  static String serverURL = "https://bizapps.tatapower.com";
  static String get SHAFingerprint => dotenv.env['SHA_FINGERPRINT'] ?? '';

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
  static const String roleByEmployee = 'role-by-employee';

  // getX function for getting the "API endpoint url"
  static getEndPointUrl(String endPointName) async {
    String endPointUrl = "";
    switch (endPointName) {
      case "roleByEmployee":
        endPointUrl = "$baseURl$roleByEmployee";
        break;
    }
    return endPointUrl;
  }
}




