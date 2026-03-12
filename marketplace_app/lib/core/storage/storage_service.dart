import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await _prefs.setString(AppConstants.accessToken, token);
  }

  static Future<String?> getToken() async {
    return _prefs.getString(AppConstants.accessToken);
  }

  static Future<void> saveRefreshToken(String token) async {
    await _prefs.setString(AppConstants.refreshToken, token);
  }

  static Future<String?> getRefreshToken() async {
    return _prefs.getString(AppConstants.refreshToken);
  }

  static Future<void> clearTokens() async {
    await _prefs.remove(AppConstants.accessToken);
    await _prefs.remove(AppConstants.refreshToken);
  }

  // User Data
  static Future<void> saveUserId(int id) async {
    await _prefs.setInt(AppConstants.userId, id);
  }

  static Future<int?> getUserId() async {
    return _prefs.getInt(AppConstants.userId);
  }

  static Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.userRole, role);
  }

  static Future<String?> getUserRole() async {
    return _prefs.getString(AppConstants.userRole);
  }

  // Login Status
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(AppConstants.isLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    return _prefs.getBool(AppConstants.isLoggedIn) ?? false;
  }

  // Onboarding
  static Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(AppConstants.onboarding, value);
  }

  static Future<bool> isOnboardingComplete() async {
    return _prefs.getBool(AppConstants.onboarding) ?? false;
  }

  // Clear All
  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Generic Methods
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
