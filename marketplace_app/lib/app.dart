import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/constants.dart';
import 'modules/auth/screens/splash_screen.dart';
import 'modules/auth/screens/login_screen.dart';
import 'modules/customer/home/screens/main_customer_screen.dart';
import 'modules/vendor/dashboard/screens/main_vendor_screen.dart';
import 'modules/driver/dashboard/screens/main_driver_screen.dart';
import 'core/storage/storage_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Widget _nextScreen = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await StorageService.isLoggedIn();
    final role = await StorageService.getUserRole();

    if (!isLoggedIn) {
      setState(() {
        _nextScreen = const LoginScreen();
      });
    } else {
      // التوجيه حسب الدور
      switch (role) {
        case AppConstants.roleCustomer:
          setState(() => _nextScreen = const MainCustomerScreen());
          break;
        case AppConstants.roleVendor:
          setState(() => _nextScreen = const MainVendorScreen());
          break;
        case AppConstants.roleDriver:
          setState(() => _nextScreen = const MainDriverScreen());
          break;
        default:
          setState(() => _nextScreen = const LoginScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _nextScreen,
    );
  }
}
