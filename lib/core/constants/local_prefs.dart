import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  // KEYS
  static const _empName = 'emp_name';
  static const _empGrade = 'emp_grade';
  static const _empEmail = 'emp_email';
  static const _empCode = 'emp_code';
  static const _roleId = 'role_id';
  static const _isLoggedIn = 'is_logged_in';

  // 🔑 THE FIX: Added a key for your Microsoft Token
  static const _accessToken = 'access_token';

  // SETTERS
  static Future<void> saveEmployeeProfile({
    String? empName,
    String? empGrade,
    String? empEmail,
  }) async
  {
    final prefs = await SharedPreferences.getInstance();
    // SETTERS - only save non-null values
    if (empName != null) {
      await prefs.setString(_empName, empName);
    }
    if (empGrade != null) {
      await prefs.setString(_empGrade, empGrade);
    }
    if (empEmail != null) {
      await prefs.setString(_empEmail, empEmail);
    }
  }

  static Future<void> saveEmpCode({
    required String empCode,
  }) async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_empCode, empCode);
  }

  static Future<void> saveRoleId({
    required int roleId,
  }) async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_roleId, roleId);
  }

  static Future<void> saveLoginStatus({
    required bool isLoggedIn,
  }) async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedIn, isLoggedIn);
  }

  // 🔑 THE FIX: Added a setter to save the token when you log in
  static Future<void> saveAccessToken({
    required String token,
  }) async
  {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessToken, token);
  }

  // GETTERS
  static Future<String?> getEmpCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empCode);
  }
  static Future<String?> getEmpName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empName);
  }
  static Future<String?> getEmpGrade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empGrade);
  }
  static Future<String?> getEmpEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_empEmail);
  }
  static Future<int?> getRoleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_roleId);
  }
  static Future<bool> getIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedIn) ?? false;
  }

  // 🔑 THE FIX: Added a getter so api_client.dart can use it!
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessToken);
  }

  // Clear stored prefs
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}