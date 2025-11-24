import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supermarket_system_phase1/models/transaction.dart';
import 'package:supermarket_system_phase1/services/transaction_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionFilter _currentFilter = TransactionFilter.all;
  String _selectedPaymentMethod = 'all';
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    final transactionService = ref.watch(transactionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المعاملات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          _buildSummaryCards(transactionService),
          
          // Filters
          _buildFilterBar(),
          
          // Transactions List
          Expanded(
            child: _buildTransactionsList(transactionService),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TransactionService transactionService) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<Map<String, double>>(
        stream: transactionService.getSalesByPaymentMethodToday(),
        builder: (context, snapshot) {
          final salesData = snapshot.data ?? {};
          final totalSales = salesData.values.fold(0.0, (sum, value) => sum + value);
          
          return Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'إجمالي المبيعات اليوم',
                  '${totalSales.toStringAsFixed(2)} ر.ي',
                  Icons.attach_money,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'المبيعات النقدية',
                  '${(salesData['cash'] ?? 0.0).toStringAsFixed(2)} ر.ي',
                  Icons.money,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'المبيعات بالبطاقة',
                  '${(salesData['card'] ?? 0.0).toStringAsFixed(2)} ر.ي',
                  Icons.credit_card,
                  AppColors.secondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('الكل'),
                    selected: _currentFilter == TransactionFilter.all,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = TransactionFilter.all;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('مبيعات'),
                    selected: _currentFilter == TransactionFilter.sales,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = TransactionFilter.sales;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('مشتريات'),
                    selected: _currentFilter == TransactionFilter.purchases,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = TransactionFilter.purchases;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('إرجاعات'),
                    selected: _currentFilter == TransactionFilter.returns,
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = TransactionFilter.returns;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (_selectedDateRange != null)
            Chip(
              label: Text(
                '${DateFormat('dd/MM').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM').format(_selectedDateRange!.end)}',
              ),
              onDeleted: () {
                setState(() {
                  _selectedDateRange = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(TransactionService transactionService) {
    Stream<List<Transaction>> transactionsStream;
    
    switch (_currentFilter) {
      case TransactionFilter.all:
        transactionsStream = transactionService.getTransactions();
        break;
      case TransactionFilter.sales:
        transactionsStream = transactionService.getSalesTransactions();
        break;
      case TransactionFilter.purchases:
        transactionsStream = transactionService.getPurchaseTransactions();
        break;
      case TransactionFilter.returns:
        transactionsStream = transactionService.getTransactionsByType('return');
        break;
    }

    return StreamBuilder<List<Transaction>>(
      stream: transactionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل المعاملات',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Transaction> transactions = snapshot.data!;
        
        // Apply filters
        transactions = _applyFilters(transactions);

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد معاملات',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                Text(
                  'لم يتم العثور على معاملات تطابق المرشحات',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction, transactionService);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction, TransactionService transactionService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTransactionDetailsDialog(transaction),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionService.formatTransactionType(transaction.type),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.userName ?? 'مستخدم غير معروف',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${transaction.netTotal.toStringAsFixed(2)} ر.ي',
                        style: AppTextStyles.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: transaction.netTotal >= 0 ? AppColors.success : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDateTime(transaction.createdAt.toDate()),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'عدد العناصر: ${transaction.items.length}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        if (transaction.paymentMethod.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                _getPaymentMethodIcon(transaction.paymentMethod),
                                size: 16,
                                color: transactionService.getPaymentMethodColor(transaction.paymentMethod),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                transactionService.formatPaymentMethod(transaction.paymentMethod),
                                style: AppTextStyles.caption.copyWith(
                                  color: transactionService.getPaymentMethodColor(transaction.paymentMethod),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: transaction.status == 'completed' 
                          ? AppColors.success.withOpacity(0.1)
                          : transaction.status == 'pending'
                              ? AppColors.warning.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      transactionService.formatTransactionStatus(transaction.status),
                      style: TextStyle(
                        color: transaction.status == 'completed' 
                            ? AppColors.success
                            : transaction.status == 'pending'
                                ? AppColors.warning
                                : AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Discount and Tax info
              if (transaction.discount > 0 || transaction.tax > 0) ...[
                const SizedBox(height: 8),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (transaction.discount > 0)
                      Text(
                        'الخصم: ${transaction.discount.toStringAsFixed(2)} ر.ي',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    if (transaction.tax > 0)
                      Text(
                        'الضريبة: ${transaction.tax.toStringAsFixed(2)} ر.ي',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Transaction> _applyFilters(List<Transaction> transactions) {
    // Apply payment method filter
    if (_selectedPaymentMethod != 'all') {
      transactions = transactions.where((t) => t.paymentMethod == _selectedPaymentMethod).toList();
    }
    
    // Apply date range filter
    if (_selectedDateRange != null) {
      transactions = transactions.where((t) {
        final transactionDate = t.createdAt.toDate();
        return transactionDate.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
               transactionDate.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    return transactions;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('فلترة المعاملات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('طريقة الدفع:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('الكل')),
                DropdownMenuItem(value: 'cash', child: Text('نقدي')),
                DropdownMenuItem(value: 'card', child: Text('بطاقة')),
                DropdownMenuItem(value: 'bank', child: Text('تحويل بنكي')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectDateRange(),
                    icon: const Icon(Icons.date_range),
                    label: const Text('اختيار تاريخ'),
                  ),
                ),
                if (_selectedDateRange != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedDateRange = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _showTransactionDetailsDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المعاملة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('الرقم التعريفي', transaction.id ?? 'غير محدد'),
              _buildDetailRow('النوع', _formatTransactionType(transaction.type)),
              _buildDetailRow('المستخدم', transaction.userName ?? 'غير معروف'),
              _buildDetailRow('التاريخ والوقت', _formatDateTime(transaction.createdAt.toDate())),
              _buildDetailRow('طريقة الدفع', _formatPaymentMethod(transaction.paymentMethod)),
              _buildDetailRow('الحالة', _formatTransactionStatus(transaction.status)),
              const Divider(),
              _buildDetailRow('المجموع الفرعي', '${transaction.total.toStringAsFixed(2)} ر.ي'),
              if (transaction.discount > 0) ...[
                _buildDetailRow('الخصم', '${transaction.discount.toStringAsFixed(2)} ر.ي'),
              ],
              if (transaction.tax > 0) ...[
                _buildDetailRow('الضريبة', '${transaction.tax.toStringAsFixed(2)} ر.ي'),
              ],
              const Divider(),
              _buildDetailRow('الإجمالي', '${transaction.netTotal.toStringAsFixed(2)} ر.ي'),
              if (transaction.isSale) ...[
                _buildDetailRow('الأرباح', '${transaction.profit.toStringAsFixed(2)} ر.ي'),
              ],
              const SizedBox(height: 16),
              const Text(
                'العناصر:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...transaction.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text((index + 1).toString()),
                    ),
                    title: Text(item.productName),
                    subtitle: Text('${item.quantity} × ${item.price.toStringAsFixed(2)} ر.ي'),
                    trailing: Text('${item.total.toStringAsFixed(2)} ر.ي'),
                  ),
                );
              }),
              if (transaction.notes != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'ملاحظات:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.notes!,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _printTransaction(transaction);
            },
            icon: const Icon(Icons.print),
            label: const Text('طباعة'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _printTransaction(Transaction transaction) {
    // Implement printing functionality
    // This would typically use a printing package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تطوير ميزة الطباعة'),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _formatTransactionType(String type) {
    switch (type) {
      case 'sale':
        return 'بيع';
      case 'purchase':
        return 'شراء';
      case 'return':
        return 'إرجاع';
      case 'expense':
        return 'مصروف';
      default:
        return type;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة';
      case 'bank':
        return 'تحويل بنكي';
      default:
        return method;
    }
  }

  String _formatTransactionStatus(String status) {
    switch (status) {
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'معلق';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
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

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}

// Enums
enum TransactionFilter {
  all,
  sales,
  purchases,
  returns,
}