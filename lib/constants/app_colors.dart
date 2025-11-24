import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32); // Green
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800); // Orange
  static const Color secondaryDark = Color(0xFFE65100);
  
  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF9F9F9);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Additional Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}

class AppDimensions {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;
  
  static const double borderRadius = 8.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 4.0;
}

class AppConstants {
  static const String appName = 'Supermarket System';
  static const String version = '1.0.0';
  static const String currency = 'YER';
  static const double taxRate = 0.15; // 15%
  
  // Roles
  static const String roleAdmin = 'admin';
  static const String roleStaff = 'staff';
  
  // Transaction Types
  static const String transactionSale = 'sale';
  static const String transactionPurchase = 'purchase';
  static const String transactionReturn = 'return';
  static const String transactionExpense = 'expense';
  
  // Payment Methods
  static const String paymentCash = 'cash';
  static const String paymentCard = 'card';
  static const String paymentBank = 'bank';
  
  // Transaction Status
  static const String statusCompleted = 'completed';
  static const String statusPending = 'pending';
  static const String statusCancelled = 'cancelled';
  
  // SharedPreferences Keys
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String tokenKey = 'token';
  static const String isLoggedInKey = 'is_logged_in';
}