import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_system_phase1/services/report_service.dart';
import 'package:supermarket_system_phase1/services/account_service.dart';
import 'package:supermarket_system_phase1/services/transaction_service.dart';
import 'package:supermarket_system_phase1/services/product_service.dart';
import 'package:supermarket_system_phase1/models/transaction.dart' as app_transaction;
import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final ReportService _reportService = ReportService();
  final AccountService _accountService = AccountService();
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();
  
  DateTime _selectedPeriod = DateTime.now();
  String _selectedPeriodType = 'today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم الإدارية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handlePeriodSelection(value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('اليوم')),
              const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'custom', child: Text('فترة مخصصة')),
            ],
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Indicator
            _buildPeriodIndicator(),
            const SizedBox(height: 24),
            
            // Key Metrics
            _buildKeyMetrics(),
            const SizedBox(height: 24),
            
            // Charts and Analytics
            _buildChartsSection(),
            const SizedBox(height: 24),
            
            // Recent Activities
            _buildRecentActivities(),
            const SizedBox(height: 24),
            
            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفترة المحددة',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _getPeriodLabel(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getPeriodTypeLabel(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المؤشرات الرئيسية',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'إجمالي المبيعات',
                value: '0 ريال',
                icon: Icons.shopping_cart,
                color: Colors.green,
                trend: '+12%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'عدد المعاملات',
                value: '0',
                icon: Icons.receipt,
                color: Colors.blue,
                trend: '+8%',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'إجمالي المصروفات',
                value: '0 ريال',
                icon: Icons.trending_down,
                color: Colors.red,
                trend: '-5%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'صافي الربح',
                value: '0 ريال',
                icon: Icons.trending_up,
                color: Colors.orange,
                trend: '+15%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  radius: 20,
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+') ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: trend.startsWith('+') ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التحليلات والإحصائيات',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Sales Chart Placeholder
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.show_chart,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'رسم بياني للمبيعات',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'سيتم عرض الرسم البياني قريباً',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Top Products and Categories
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'أفضل المنتجات',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Placeholder for top products
                      _buildPlaceholderList(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'أفضل الفئات',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Placeholder for top categories
                      _buildPlaceholderList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderList() {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'منتج ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '0 مبيعة',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأنشطة الأخيرة',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(Icons.shopping_cart, color: Colors.green),
                ),
                title: const Text('معاملة جديدة'),
                subtitle: Text(
                  _formatDateTime(DateTime.now()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: Text(
                  '+150 ريال',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.inventory, color: Colors.blue),
                ),
                title: const Text('تم إضافة منتج جديد'),
                subtitle: Text(
                  _formatDateTime(DateTime.now().subtract(const Duration(hours: 2))),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(Icons.account_balance_wallet, color: Colors.orange),
                ),
                title: const Text('حركة مالية جديدة'),
                subtitle: Text(
                  _formatDateTime(DateTime.now().subtract(const Duration(hours: 4))),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                trailing: Text(
                  '-50 ريال',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              title: 'إنشاء تقرير',
              subtitle: 'تقرير سريع',
              icon: Icons.analytics,
              color: Colors.green,
              onTap: () => _createQuickReport(),
            ),
            _buildActionCard(
              title: 'إدارة المخزون',
              subtitle: 'منتجات ومخزون',
              icon: Icons.inventory,
              color: Colors.blue,
              onTap: () => _openInventoryManagement(),
            ),
            _buildActionCard(
              title: 'إدارة الحسابات',
              subtitle: 'حسابات ومالية',
              icon: Icons.account_balance_wallet,
              color: Colors.orange,
              onTap: () => _openFinanceManagement(),
            ),
            _buildActionCard(
              title: 'إعدادات النظام',
              subtitle: 'تخصيص التطبيق',
              icon: Icons.settings,
              color: Colors.purple,
              onTap: () => _openSystemSettings(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                radius: 24,
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Quick Actions Handlers
  void _createQuickReport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickReportSheet(),
    );
  }

  Widget _buildQuickReportSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'إنشاء تقرير سريع',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildReportOption(
                        icon: Icons.today,
                        title: 'التقرير اليومي',
                        subtitle: 'مبيعات اليوم',
                        onTap: () => _generateReport('daily'),
                      ),
                      _buildReportOption(
                        icon: Icons.calendar_view_week,
                        title: 'التقرير الأسبوعي',
                        subtitle: 'مبيعات الأسبوع',
                        onTap: () => _generateReport('weekly'),
                      ),
                      _buildReportOption(
                        icon: Icons.calendar_month,
                        title: 'التقرير الشهري',
                        subtitle: 'مبيعات الشهر',
                        onTap: () => _generateReport('monthly'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _openInventoryManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح إدارة المخزون قريباً')),
    );
  }

  void _openFinanceManagement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح إدارة الحسابات المالية قريباً')),
    );
  }

  void _openSystemSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم فتح إعدادات النظام قريباً')),
    );
  }

  // Report Generation
  Future<void> _generateReport(String type) async {
    Navigator.of(context).pop();
    
    try {
      DateTime startDate = DateTime.now();
      DateTime endDate = DateTime.now();
      
      switch (type) {
        case 'daily':
          // Already set to today
          break;
        case 'weekly':
          startDate = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
          endDate = startDate.add(const Duration(days: 6));
          break;
        case 'monthly':
          startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
          endDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
          break;
      }
      
      Map<String, dynamic> reportData = {};
      
      switch (type) {
        case 'daily':
          reportData = await _reportService.generateDailyReport(DateTime.now(), 'admin');
          break;
        case 'weekly':
          reportData = await _reportService.generateWeeklyReport(DateTime.now(), 'admin');
          break;
        case 'monthly':
          reportData = await _reportService.generateMonthlyReport(
            DateTime.now().year, 
            DateTime.now().month, 
            'admin',
          );
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إنشاء التقرير ${_getReportTypeName(type)} بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في إنشاء التقرير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Period Selection Handler
  void _handlePeriodSelection(String value) {
    setState(() {
      _selectedPeriodType = value;
      _selectedPeriod = DateTime.now();
    });
  }

  // Helper Methods
  String _getPeriodLabel() {
    switch (_selectedPeriodType) {
      case 'today':
        return _formatDate(DateTime.now());
      case 'week':
        final startOfWeek = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
      case 'month':
        return _formatMonth(DateTime.now());
      case 'custom':
        return 'فترة مخصصة';
      default:
        return _formatDate(DateTime.now());
    }
  }

  String _getPeriodTypeLabel() {
    switch (_selectedPeriodType) {
      case 'today':
        return 'يومي';
      case 'week':
        return 'أسبوعي';
      case 'month':
        return 'شهري';
      case 'custom':
        return 'مخصص';
      default:
        return 'يومي';
    }
  }

  String _getReportTypeName(String type) {
    switch (type) {
      case 'daily':
        return 'اليومي';
      case 'weekly':
        return 'الأسبوعي';
      case 'monthly':
        return 'الشهري';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}