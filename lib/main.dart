import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/app_provider.dart';
import 'utils/theme.dart';
import 'utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize local storage
  await Storage.init();
  
  runApp(
    ProviderScope(
      child: SupermarketApp(),
    ),
  );
}

class SupermarketApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'نظام إدارة السوبر ماركت',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: _getInitialScreen(authState),
    );
  }
  
  Widget _getInitialScreen(AsyncValue authState) {
    if (authState.isLoading) {
      return SplashScreen();
    }
    
    if (authState.hasError) {
      return LoginScreen();
    }
    
    final user = authState.value;
    if (user != null) {
      return MainScreen();
    }
    
    return LoginScreen();
  }
}