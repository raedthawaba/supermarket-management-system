import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_state.freezed.dart';
part 'app_state.g.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    @Default('ar') String language,
    @Default(ThemeMode.light) ThemeMode themeMode,
    @Default(false) bool isLoading,
    @Default(true) bool isConnected,
    DateTime? lastSync,
    @Default('1.0.0') String appVersion,
    @Default('') String deviceId,
    @Default('') String fcmToken,
  }) = _AppState;

  factory AppState.fromJson(Map<String, dynamic> json) =>
      _$AppStateFromJson(json);
}

extension AppStateExtension on AppState {
  bool get isDarkMode => themeMode == ThemeMode.dark;
  
  String get languageDisplayName {
    switch (language) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'العربية';
    }
  }
  
  bool get needsSync => lastSync == null || 
      DateTime.now().difference(lastSync!).inMinutes > 30;
}