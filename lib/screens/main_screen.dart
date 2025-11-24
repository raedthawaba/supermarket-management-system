import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_system_phase1/screens/dashboard_screen.dart';
import 'package:supermarket_system_phase1/screens/products_screen.dart';
import 'package:supermarket_system_phase1/screens/pos_screen.dart';
import 'package:supermarket_system_phase1/screens/transactions_screen.dart';
import 'package:supermarket_system_phase1/screens/reports_screen.dart';
import 'package:supermarket_system_phase1/screens/finance_screen.dart';
import 'package:supermarket_system_phase1/screens/admin_dashboard_screen.dart';
import 'package:supermarket_system_phase1/services/auth_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const POSScreen(),
    const ProductsScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const FinanceScreen(),
    const AdminDashboardScreen(),
  ];

  final List<String> _titles = [
    'لوحة التحكم',
    'نقطة البيع',
    'إدارة المنتجات',
    'المعاملات',
    'التقارير',
    'الحسابات المالية',
    'لوحة الإدارة',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.point_of_sale,
    Icons.inventory_2,
    Icons.receipt,
    Icons.analytics,
    Icons.account_balance_wallet,
    Icons.admin_panel_settings,
  ];

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // User Info
          if (user != null) ...[
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => _showUserMenu(context),
            ),
          ],
          
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
          ),
        ],
      ),
      
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      
      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: List.generate(_titles.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          );
        }),
      ),

      // Floating Action Button for POS
      floatingActionButton: _selectedIndex != 1 ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _selectedIndex = 1; // Switch to POS
          });
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.point_of_sale,
          color: Colors.white,
        ),
      ) : null,
    );
  }

  void _showUserMenu(BuildContext context) {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'المستخدم',
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user?.isAdmin == true 
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user?.isAdmin == true ? 'مسؤول' : 'عامل',
                style: TextStyle(
                  color: user?.isAdmin == true 
                      ? AppColors.primary 
                      : AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to profile settings
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('الإعدادات'),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleLogout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('تسجيل الخروج'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تسجيل الخروج: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});