import 'package:flutter/material.dart';

import '../constants/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المعاملات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'المبيعات'),
              Tab(text: 'المردودات'),
              Tab(text: 'التسويات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionsList('sales'),
            _buildTransactionsList('returns'),
            _buildTransactionsList('adjustments'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(String type) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long,
                color: AppColors.primary,
              ),
            ),
            title: Text('معاملة ${index + 1}'),
            subtitle: Text('الكاشير: أحمد محمد'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '150 ريال',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'منذ ${index + 1} ساعة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Handle transaction details
            },
          ),
        );
      },
    );
  }
}