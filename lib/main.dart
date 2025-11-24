import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'utils/firebase_setup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with fallback
  await initializeFirebase();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      child: const SupermarketApp(),
    ),
  );
}

class SupermarketApp extends ConsumerWidget {
  const SupermarketApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);

    return MaterialApp(
      title: 'Supermarket System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        fontFamily: 'Cairo',
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Color(0xFFFF9800),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFF5F5F5),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF2E7D32),
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainScreen(),
      },
      // Check authentication state on startup
      builder: (context, child) {
        return FutureBuilder<bool>(
          future: _checkAuthState(authService),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Material(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final isLoggedIn = snapshot.data ?? false;
            
            return Material(
              child: isLoggedIn ? const MainScreen() : const LoginScreen(),
            );
          },
        );
      },
    );
  }

  Future<bool> _checkAuthState(AuthService authService) async {
    try {
      await authService.loadUserFromPreferences();
      return authService.isLoggedIn;
    } catch (e) {
      return false;
    }
  }
}