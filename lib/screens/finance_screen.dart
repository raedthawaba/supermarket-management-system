import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_system_phase1/models/account.dart';
import 'package:supermarket_system_phase1/models/financial_transaction.dart';
import 'package:supermarket_system_phase1/services/account_service.dart';
import 'package:supermarket_system_phase1/services/auth_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  final AccountService _accountService = AccountService();
  
  int _selectedIndex = 0;
  Account? _selectedAccount;
  
  final List<String> _tabTitles = [
    'الحسابات',
    'الحركات المالية',
  ];
  
  final List<IconData> _tabIcons = [
    Icons.account_balance_wallet,
    Icons.swap_horiz,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitles[_selectedIndex]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _selectedIndex == 0 ? _showAddAccountDialog() : _showAddTransactionDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAccountsTab(),
          _buildTransactionsTab(),
        ],
      ),
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
        items: List.generate(_tabTitles.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_tabIcons[index]),
            label: _tabTitles[index],
          );
        }),
      ),
    );
  }

  Widget _buildAccountsTab() {
    return StreamBuilder<List<Account>>(
      stream: _accountService.getAllAccounts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ في تحميل الحسابات: ${snapshot.error}'),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final accounts = snapshot.data ?? [];
        
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary Cards
              _buildAccountsSummary(accounts),
              const SizedBox(height: 24),
              
              // Accounts List
              if (accounts.isEmpty) ...[
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد حسابات',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط على + لإضافة حساب جديد',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...accounts.map((account) => _buildAccountCard(account)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountsSummary(List<Account> accounts) {
    double totalBalance = accounts.fold(0.0, (sum, account) => sum + account.currentBalance);
    int cashAccounts = accounts.where((acc) => acc.type == 'cash').length;
    int bankAccounts = accounts.where((acc) => acc.type == 'bank').length;
    
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'إجمالي الرصيد',
            value: '${totalBalance.toStringAsFixed(2)} ريال',
            icon: Icons.account_balance_wallet,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            title: 'حسابات نقدية',
            value: cashAccounts.toString(),
            icon: Icons.monetization_on,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            title: 'حسابات بنكية',
            value: bankAccounts.toString(),
            icon: Icons.account_balance,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 20,
              child: Icon(icon, color: color, size: 24),
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

  Widget _buildAccountCard(Account account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(account.typeIcon, color: AppColors.primary),
        ),
        title: Text(account.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.typeDisplayName),
            if (account.bankName != null) Text(account.bankName!),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${account.currentBalance.toStringAsFixed(2)} ${account.currency}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (account.currentBalance != account.initialBalance)
              Text(
                'الرصيد الأولي: ${account.initialBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        onTap: () => _showAccountDetails(account),
        onLongPress: () => _showAccountOptions(account),
      ),
    );
  }

  Widget _buildTransactionsTab() {
    return StreamBuilder<List<FinancialTransaction>>(
      stream: _accountService.getAllTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('خطأ في تحميل الحركات: ${snapshot.error}'),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        final transactions = snapshot.data ?? [];
        
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Financial Summary
              _buildFinancialSummary(transactions),
              const SizedBox(height: 24),
              
              // Filter Options
              _buildFilterOptions(),
              const SizedBox(height: 16),
              
              // Transactions List
              if (transactions.isEmpty) ...[
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد حركات مالية',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط على + لإضافة حركة جديدة',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...transactions.map((transaction) => _buildTransactionCard(transaction)),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialSummary(List<FinancialTransaction> transactions) {
    double totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    double totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
    
    double netAmount = totalIncome - totalExpense;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الملخص المالي',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    'إجمالي الدخل',
                    totalIncome,
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    'إجمالي المصروفات',
                    totalExpense,
                    Icons.trending_down,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: netAmount >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    netAmount >= 0 ? Icons.balance : Icons.warning,
                    color: netAmount >= 0 ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'صافي المبلغ: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${netAmount.toStringAsFixed(2)} ريال',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: netAmount >= 0 ? Colors.green : Colors.red,
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

  Widget _buildFinancialCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} ريال',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'نوع الحركة',
              prefixIcon: Icon(Icons.filter_list),
            ),
            items: const [
              DropdownMenuItem(value: '', child: Text('الكل')),
              DropdownMenuItem(value: 'income', child: Text('دخل')),
              DropdownMenuItem(value: 'expense', child: Text('مصروف')),
              DropdownMenuItem(value: 'transfer', child: Text('تحويل')),
            ],
            onChanged: (value) {
              // Apply filter
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDateRangeFilter(),
            icon: const Icon(Icons.date_range),
            label: const Text('التاريخ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionCard(FinancialTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.typeColor.withOpacity(0.1),
          child: Icon(transaction.typeIcon, color: transaction.typeColor),
        ),
        title: Text(transaction.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transaction.typeDisplayName} • ${transaction.category}',
              style: TextStyle(
                color: transaction.typeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatDateTime(transaction.date),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.amount.toStringAsFixed(2)} ريال',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.typeColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: transaction.status == 'completed' 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transaction.status == 'completed' ? 'مكتمل' : 'معلق',
                style: TextStyle(
                  fontSize: 10,
                  color: transaction.status == 'completed' ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
        onLongPress: () => _showTransactionOptions(transaction),
      ),
    );
  }

  // Show Add Account Dialog
  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddAccountDialog(),
    );
  }

  // Show Add Transaction Dialog
  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  // Show Account Details
  void _showAccountDetails(Account account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountDetailSheet(account: account),
    );
  }

  // Show Account Options
  void _showAccountOptions(Account account) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل'),
              onTap: () {
                Navigator.pop(context);
                // Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(account);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show Transaction Details
  void _showTransactionDetails(FinancialTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailSheet(transaction: transaction),
    );
  }

  // Show Transaction Options
  void _showTransactionOptions(FinancialTransaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('تعديل'),
              onTap: () {
                Navigator.pop(context);
                // Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteTransactionConfirmation(transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Show Delete Confirmation
  void _showDeleteConfirmation(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف حساب "${account.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _accountService.deleteAccount(account.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الحساب بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في حذف الحساب: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // Show Delete Transaction Confirmation
  void _showDeleteTransactionConfirmation(FinancialTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الحركة المالية؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await _accountService.deleteFinancialTransaction(
                  transaction.id,
                  transaction.accountId,
                  transaction.amount,
                  transaction.type,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف الحركة بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في حذف الحركة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // Show Date Range Filter
  void _showDateRangeFilter() {
    showDialog(
      context: context,
      builder: (context) => const DateRangeFilterDialog(),
    );
  }

  // Helper Methods
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Add Account Dialog (placeholder)
class AddAccountDialog extends StatelessWidget {
  const AddAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة حساب جديد'),
      content: const Text('سيتم تطوير نموذج إضافة الحسابات قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

// Add Transaction Dialog (placeholder)
class AddTransactionDialog extends StatelessWidget {
  const AddTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة حركة مالية'),
      content: const Text('سيتم تطوير نموذج إضافة الحركات المالية قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

// Date Range Filter Dialog (placeholder)
class DateRangeFilterDialog extends StatelessWidget {
  const DateRangeFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تصفية حسب التاريخ'),
      content: const Text('سيتم تطوير تصفية التاريخ قريباً'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('موافق'),
        ),
      ],
    );
  }
}

// Account Detail Sheet (placeholder)
class AccountDetailSheet extends StatelessWidget {
  final Account account;

  const AccountDetailSheet({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Icon(account.typeIcon, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            account.typeDisplayName,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('الرصيد الحالي', '${account.currentBalance.toStringAsFixed(2)} ${account.currency}'),
                      _buildDetailRow('الرصيد الأولي', '${account.initialBalance.toStringAsFixed(2)} ${account.currency}'),
                      if (account.bankName != null) _buildDetailRow('اسم البنك', account.bankName!),
                      if (account.accountNumber != null) _buildDetailRow('رقم الحساب', account.accountNumber!),
                      if (account.iban != null) _buildDetailRow('IBAN', account.iban!),
                      if (account.description != null) _buildDetailRow('الوصف', account.description!),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// Transaction Detail Sheet (placeholder)
class TransactionDetailSheet extends StatelessWidget {
  final FinancialTransaction transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
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
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: transaction.typeColor.withOpacity(0.1),
                      child: Icon(transaction.typeIcon, color: transaction.typeColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.description,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Text(
                            transaction.typeDisplayName,
                            style: TextStyle(
                              color: transaction.typeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('المبلغ', '${transaction.amount.toStringAsFixed(2)} ريال'),
                      _buildDetailRow('الفئة', transaction.category),
                      _buildDetailRow('التاريخ', _formatDateTime(transaction.date)),
                      if (transaction.referenceNumber != null) 
                        _buildDetailRow('رقم المرجع', transaction.referenceNumber!),
                      if (transaction.notes != null) 
                        _buildDetailRow('ملاحظات', transaction.notes!),
                      _buildDetailRow('الحالة', transaction.status == 'completed' ? 'مكتمل' : 'معلق'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}