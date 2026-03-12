import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) => _buildOrderCard(context),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'طلب #12345',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'جديد',
                  style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(),
          const Row(
            children: [
              Icon(Icons.person, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text('اسم العميل', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text('العنوان', style: TextStyle(fontSize: 12)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('3 منتجات', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const Text('85 ر.س', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('رفض'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('قبول'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
