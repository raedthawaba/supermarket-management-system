import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../models/app_state.dart';

class AppService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw 'AppService not initialized. Call init() first.';
    }
    return _prefs!;
  }

  AppState getInitialState() {
    final language = prefs.getString('language') ?? 'ar';
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    final lastSyncString = prefs.getString('lastSync');
    
    return AppState(
      language: language,
      themeMode: ThemeMode.values[themeModeIndex],
      lastSync: lastSyncString != null ? DateTime.parse(lastSyncString) : null,
      appVersion: prefs.getString('appVersion') ?? '1.0.0',
      deviceId: prefs.getString('deviceId') ?? '',
      fcmToken: prefs.getString('fcmToken') ?? '',
    );
  }

  Future<void> saveLanguage(String language) async {
    await prefs.setString('language', language);
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await prefs.setInt('themeMode', themeMode.index);
  }

  Future<void> saveLastSync(DateTime lastSync) async {
    await prefs.setString('lastSync', lastSync.toIso8601String());
  }

  Future<void> saveDeviceId(String deviceId) async {
    await prefs.setString('deviceId', deviceId);
  }

  Future<void> saveFcmToken(String token) async {
    await prefs.setString('fcmToken', token);
  }

  Future<void> clearUserData() async {
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('userEmail');
  }

  String get language => prefs.getString('language') ?? 'ar';
  
  ThemeMode get themeMode {
    final index = prefs.getInt('themeMode') ?? 0;
    return ThemeMode.values[index];
  }

  bool get isFirstLaunch => prefs.getBool('isFirstLaunch') ?? true;

  Future<void> setFirstLaunchCompleted() async {
    await prefs.setBool('isFirstLaunch', false);
  }
}