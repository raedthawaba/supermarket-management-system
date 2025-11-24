import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_system_phase1/services/report_service.dart';
import 'package:supermarket_system_phase1/services/export_service.dart';
import 'package:supermarket_system_phase1/services/auth_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final ReportService _reportService = ReportService();
  final ExportService _exportService = ExportService();
  
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = 'daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التقارير'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Report Generation
            _buildQuickReportSection(),
            const SizedBox(height: 24),
            
            // Period Selection
            _buildPeriodSelection(),
            const SizedBox(height: 24),
            
            // Reports List
            _buildReportsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReportSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إنشاء تقرير سريع',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Daily Report
            _buildQuickReportButton(
              icon: Icons.today,
              title: 'التقرير اليومي',
              subtitle: _formatDate(_selectedDate),
              onTap: () => _generateDailyReport(),
            ),
            
            // Weekly Report
            _buildQuickReportButton(
              icon: Icons.calendar_view_week,
              title: 'التقرير الأسبوعي',
              subtitle: _getWeekRange(DateTime.now()),
              onTap: () => _generateWeeklyReport(DateTime.now()),
            ),
            
            // Monthly Report
            _buildQuickReportButton(
              icon: Icons.calendar_month,
              title: 'التقرير الشهري',
              subtitle: _formatMonth(DateTime.now()),
              onTap: () => _generateMonthlyReport(DateTime.now().year, DateTime.now().month),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReportButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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

  Widget _buildPeriodSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تحديد الفترة',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Period Type
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'نوع الفترة',
                prefixIcon: Icon(Icons.timeline),
              ),
              items: const [
                DropdownMenuItem(value: 'daily', child: Text('يومي')),
                DropdownMenuItem(value: 'weekly', child: Text('أسبوعي')),
                DropdownMenuItem(value: 'monthly', child: Text('شهري')),
                DropdownMenuItem(value: 'custom', child: Text('مخصص')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date Selection based on period
            if (_selectedPeriod == 'custom') ...[
              Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      label: 'من',
                      date: _startDate,
                      onTap: () => _selectDate('start'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateButton(
                      label: 'إلى',
                      date: _endDate,
                      onTap: () => _selectDate('end'),
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Generate Custom Report Button
            ElevatedButton.icon(
              onPressed: _generateCustomReport,
              icon: const Icon(Icons.analytics),
              label: const Text('إنشاء تقرير'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(date),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التقارير المحفوظة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            StreamBuilder(
              stream: _reportService.getAllReports(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطأ في تحميل التقارير: ${snapshot.error}'),
                  );
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                final reports = snapshot.data ?? [];
                
                if (reports.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'لا توجد تقارير محفوظة',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'قم بإنشاء تقرير جديد لبدء التحليل',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportItem(report);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(dynamic report) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getReportTypeColor(report.type).withOpacity(0.1),
        child: Icon(
          _getReportTypeIcon(report.type),
          color: _getReportTypeColor(report.type),
        ),
      ),
      title: Text(report.title),
      subtitle: Text(
        '${report.typeDisplayName} • ${_formatDateTime(report.generatedAt)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleReportAction(value, report),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'view',
            child: Row(
              children: [
                Icon(Icons.visibility, size: 20),
                SizedBox(width: 8),
                Text('عرض'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export_csv',
            child: Row(
              children: [
                Icon(Icons.table_chart, size: 20),
                SizedBox(width: 8),
                Text('تصدير CSV'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'export_pdf',
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, size: 20),
                SizedBox(width: 8),
                Text('تصدير PDF'),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _viewReport(report),
    );
  }

  // Generate Daily Report
  Future<void> _generateDailyReport() async {
    try {
      final authService = ref.read(authServiceProvider);
      await _reportService.generateDailyReport(_selectedDate, authService.currentUser?.id ?? '');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء التقرير اليومي بنجاح'),
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

  // Generate Weekly Report
  Future<void> _generateWeeklyReport(DateTime date) async {
    try {
      final authService = ref.read(authServiceProvider);
      await _reportService.generateWeeklyReport(date, authService.currentUser?.id ?? '');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء التقرير الأسبوعي بنجاح'),
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

  // Generate Monthly Report
  Future<void> _generateMonthlyReport(int year, int month) async {
    try {
      final authService = ref.read(authServiceProvider);
      await _reportService.generateMonthlyReport(year, month, authService.currentUser?.id ?? '');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء التقرير الشهري بنجاح'),
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

  // Generate Custom Report
  Future<void> _generateCustomReport() async {
    // For now, show a simple dialog. Can be expanded with more options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('التقرير المخصص'),
        content: const Text('سيتم إنشاء تقرير مخصص للفترة المحددة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Generate custom report logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم تطوير التقرير المخصص قريباً'),
                ),
              );
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  // Handle Report Actions
  void _handleReportAction(String action, dynamic report) {
    switch (action) {
      case 'view':
        _viewReport(report);
        break;
      case 'export_csv':
        _exportReportCSV(report);
        break;
      case 'export_pdf':
        _exportReportPDF(report);
        break;
    }
  }

  // View Report
  void _viewReport(dynamic report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportDetailSheet(report: report),
    );
  }

  // Export Report to CSV
  Future<void> _exportReportCSV(dynamic report) async {
    try {
      // This would typically extract the data and export as CSV
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم تطوير تصدير CSV قريباً'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في التصدير: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Export Report to PDF
  Future<void> _exportReportPDF(dynamic report) async {
    try {
      final file = await _exportService.generatePDFReport(
        title: report.title,
        data: report.data,
        filename: 'report_${report.id}',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تصدير التقرير بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في تصدير التقرير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Select Date
  Future<void> _selectDate(String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: type == 'start' ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (type == 'start') {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  // Helper Methods
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

  String _getWeekRange(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Color _getReportTypeColor(String type) {
    switch (type) {
      case 'daily':
        return Colors.blue;
      case 'weekly':
        return Colors.green;
      case 'monthly':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportTypeIcon(String type) {
    switch (type) {
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.calendar_view_week;
      case 'monthly':
        return Icons.calendar_month;
      default:
        return Icons.analytics;
    }
  }
}

// Report Detail Bottom Sheet
class ReportDetailSheet extends StatelessWidget {
  final dynamic report;

  const ReportDetailSheet({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${report.typeDisplayName} • ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _buildReportContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReportContent() {
    // This would display the actual report data
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تفاصيل التقرير',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Summary Cards
        if (report.data['summary'] != null) ...[
          _buildSummaryCard(
            'إجمالي المبيعات',
            '${report.data['summary']['totalSales']?.toStringAsFixed(2) ?? '0.00'} ريال',
            Icons.shopping_cart,
            Colors.green,
          ),
          const SizedBox(height: 8),
          _buildSummaryCard(
            'عدد المعاملات',
            report.data['summary']['totalTransactions']?.toString() ?? '0',
            Icons.receipt,
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildSummaryCard(
            'صافي الربح',
            '${report.data['summary']['netProfit']?.toStringAsFixed(2) ?? '0.00'} ريال',
            Icons.trending_up,
            Colors.orange,
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Top Products
        if (report.data['summary']?['topProducts'] != null && 
            (report.data['summary']['topProducts'] as List).isNotEmpty) ...[
          const Text(
            'أفضل المنتجات مبيعاً',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...((report.data['summary']['topProducts'] as List).take(5).map((product) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: const Icon(Icons.inventory_2, color: Colors.blue),
                ),
                title: Text(product['productName'] ?? 'غير محدد'),
                trailing: Text(
                  '${product['totalSales']?.toStringAsFixed(2) ?? '0.00'} ريال',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          })),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}