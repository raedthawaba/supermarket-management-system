import 'package:flutter/material.dart';

import '../constants/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير والإحصائيات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'يومية'),
              Tab(text: 'أسبوعية'),
              Tab(text: 'شهرية'),
              Tab(text: 'مخصصة'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyReport(),
            _buildWeeklyReport(),
            _buildMonthlyReport(),
            _buildCustomReport(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyReport() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildReportCard(
                  'إجمالي المبيعات',
                  '2,450 ريال',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildReportCard(
                  'عدد المعاملات',
                  '45',
                  Icons.receipt_long,
                  AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildReportCard(
                  'أعلى منتج مبيعاً',
                  'منتج 1',
                  Icons.inventory,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildReportCard(
                  'متوسط الفاتورة',
                  '54 ريال',
                  Icons.calculate,
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Top Products
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أفضل المنتجات مبيعاً',
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(5, (index) => _buildProductRank(index + 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyReport() {
    return const Center(
      child: Text('تقرير أسبوعي - قريباً'),
    );
  }

  Widget _buildMonthlyReport() {
    return const Center(
      child: Text('تقرير شهري - قريباً'),
    );
  }

  Widget _buildCustomReport() {
    return const Center(
      child: Text('تقرير مخصص - قريباً'),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRank(int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.warning : AppColors.textSecondary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('منتج $rank'),
          ),
          Text(
            '150 ريال',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}