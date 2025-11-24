import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_system_phase1/services/transaction_service.dart';
import 'package:supermarket_system_phase1/services/product_service.dart';
import 'package:supermarket_system_phase1/services/auth_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionService = ref.watch(transactionServiceProvider);
    final productService = ref.watch(productServiceProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      body: StreamBuilder<double>(
        stream: transactionService.getTotalSalesToday(),
        builder: (context, snapshot) {
          final totalSales = snapshot.data ?? 0.0;
          
          return StreamBuilder<double>(
            stream: transactionService.getTotalProfitToday(),
            builder: (context, snapshot) {
              final totalProfit = snapshot.data ?? 0.0;
              
              return StreamBuilder<int>(
                stream: transactionService.getSalesCountToday(),
                builder: (context, snapshot) {
                  final salesCount = snapshot.data ?? 0;
                  
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Message
                        _buildWelcomeCard(authService.currentUser),
                        const SizedBox(height: 16),
                        
                        // Quick Stats
                        _buildQuickStats(totalSales, totalProfit, salesCount),
                        const SizedBox(height: 24),
                        
                        // Quick Actions
                        _buildQuickActions(context, authService),
                        const SizedBox(height: 24),
                        
                        // Recent Transactions
                        _buildRecentTransactions(),
                        const SizedBox(height: 24),
                        
                        // Low Stock Alert
                        _buildLowStockAlert(productService),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً، ${user?.name ?? 'المستخدم'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user?.isAdmin == true 
                      ? 'مرحباً بك في لوحة تحكم الإدارة'
                      : 'مرحباً بك في نظام السوبرماركت',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              user?.isAdmin == true ? Icons.admin_panel_settings : Icons.store,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(double totalSales, double totalProfit, int salesCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات اليوم',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي المبيعات',
                '${totalSales.toStringAsFixed(2)} ر.ي',
                Icons.attach_money,
                AppColors.success,
                true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'الأرباح',
                '${totalProfit.toStringAsFixed(2)} ر.ي',
                Icons.trending_up,
                AppColors.primary,
                true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'عدد المبيعات',
                salesCount.toString(),
                Icons.shopping_cart,
                AppColors.secondary,
                false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'متوسط العملية',
                totalSales > 0 ? '${(totalSales / salesCount).toStringAsFixed(2)} ر.ي' : '0 ر.ي',
                Icons.analytics,
                AppColors.info,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isMoney) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthService authService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'نقطة البيع',
                'إجراء بيع جديد',
                Icons.point_of_sale,
                AppColors.primary,
                () => Navigator.pushNamed(context, '/pos'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                'إضافة منتج',
                'إضافة منتج جديد',
                Icons.add_box,
                AppColors.success,
                () => Navigator.pushNamed(context, '/products?action=add'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'إدارة المخزون',
                'عرض وإدارة المنتجات',
                Icons.inventory_2,
                AppColors.secondary,
                () => Navigator.pushNamed(context, '/products'),
              ),
            ),
            const SizedBox(width: 16),
            if (authService.canViewReports) ...[
              Expanded(
                child: _buildActionCard(
                  'التقارير',
                  'عرض التقارير',
                  Icons.analytics,
                  AppColors.info,
                  () => Navigator.pushNamed(context, '/reports'),
                ),
              ),
            ] else ...[
              const Spacer(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactionService = ref.watch(transactionServiceProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المعاملات الحديثة',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Transaction>>(
          stream: transactionService.getTransactions(limit: 5),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Card(
                child: ListTile(
                  leading: Icon(Icons.error),
                  title: Text('خطأ في تحميل المعاملات'),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Card(
                child: ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('جاري التحميل...'),
                ),
              );
            }

            final transactions = snapshot.data!;
            
            if (transactions.isEmpty) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.inbox),
                  title: const Text('لا توجد معاملات'),
                  subtitle: const Text('لم يتم إجراء أي معاملات بعد'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: transactionService.getTransactionTypeColor(transaction.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTransactionIcon(transaction.type),
                        color: transactionService.getTransactionTypeColor(transaction.type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transactionService.formatTransactionType(transaction.type),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${transaction.items.length} عنصر • ${transaction.userName ?? "مستخدم"}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${transaction.netTotal.toStringAsFixed(2)} ر.ي',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatTime(transaction.createdAt.toDate()),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLowStockAlert(WidgetRef ref) {
    return StreamBuilder<List<Product>>(
      stream: ref.watch(productServiceProvider).getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        
        final products = snapshot.data!;
        final lowStockProducts = products.where((p) => p.isLowStock).toList();
        
        if (lowStockProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Card(
          color: AppColors.warning.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تنبيه: مخزون منخفض',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'يوجد ${lowStockProducts.length} منتج بمخزون منخفض',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/products?filter=low_stock'),
                  icon: const Icon(Icons.inventory_2, size: 18),
                  label: const Text('عرض المنتجات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'sale':
        return Icons.shopping_cart;
      case 'purchase':
        return Icons.local_shipping;
      case 'return':
        return Icons.undo;
      case 'expense':
        return Icons.money_off;
      default:
        return Icons.receipt;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inHours < 1) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inDays < 1) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return 'منذ ${diff.inDays} يوم';
    }
  }
}

// Providers
final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService();
});

final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});