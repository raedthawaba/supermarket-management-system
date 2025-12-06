import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/app_state.dart';
import '../services/app_service.dart';

part 'app_provider.g.dart';

@Riverpod(keepAlive: true)
class AppNotifier extends _$AppNotifier {
  late final AppService _appService;

  @override
  AppState build() {
    _appService = ref.read(appServiceProvider);
    return _appService.getInitialState();
  }

  void updateLanguage(String languageCode) {
    state = state.copyWith(language: languageCode);
    _appService.saveLanguage(languageCode);
  }

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _appService.saveThemeMode(themeMode);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void updateConnectionStatus(bool isConnected) {
    state = state.copyWith(isConnected: isConnected);
  }

  void updateLastSync(DateTime lastSync) {
    state = state.copyWith(lastSync: lastSync);
    _appService.saveLastSync(lastSync);
  }
}

@riverpod
AppService appService(AppServiceRef ref) {
  return AppService();
}