import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supermarket_system_phase1/models/report.dart';
import 'package:supermarket_system_phase1/models/transaction.dart';
import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/services/transaction_service.dart';
import 'package:supermarket_system_phase1/services/product_service.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TransactionService _transactionService = TransactionService();
  final ProductService _productService = ProductService();
  
  CollectionReference get reportsCollection => _firestore.collection('reports');

  // Generate Daily Report
  Future<Map<String, dynamic>> generateDailyReport(DateTime date, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    
    final salesSummary = await _getSalesSummary(startOfDay, endOfDay);
    final inventorySummary = await _getInventorySummary();
    final financialSummary = await _getFinancialSummary(startOfDay, endOfDay);
    
    final reportData = {
      'date': date.toIso8601String(),
      'sales': salesSummary,
      'inventory': inventorySummary,
      'financial': financialSummary,
      'summary': {
        'totalSales': salesSummary['totalAmount'] ?? 0.0,
        'totalTransactions': salesSummary['totalCount'] ?? 0,
        'topProducts': salesSummary['topProducts'] ?? [],
        'totalRevenue': financialSummary['totalIncome'] ?? 0.0,
        'totalExpenses': financialSummary['totalExpense'] ?? 0.0,
        'netProfit': (financialSummary['totalIncome'] ?? 0.0) - (financialSummary['totalExpense'] ?? 0.0),
      },
    };
    
    // Save report to Firestore
    final report = Report(
      id: '',
      title: 'التقرير اليومي - ${_formatDate(date)}',
      type: 'daily',
      startDate: startOfDay,
      endDate: endOfDay,
      data: reportData,
      generatedAt: DateTime.now(),
      generatedBy: userId,
      notes: 'تقرير يومي شامل للمبيعات والمخزون والمالية',
    );
    
    await saveReport(report);
    
    return reportData;
  }

  // Generate Weekly Report
  Future<Map<String, dynamic>> generateWeeklyReport(DateTime startDate, String userId) async {
    final startOfWeek = startDate.subtract(Duration(days: startDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
    
    final dailyReports = <Map<String, dynamic>>[];
    
    for (int i = 0; i < 7; i++) {
      final dayDate = startOfWeek.add(Duration(days: i));
      final dayData = await _getSalesSummary(
        DateTime(dayDate.year, dayDate.month, dayDate.day),
        DateTime(dayDate.year, dayDate.month, dayDate.day, 23, 59, 59)
      );
      dailyReports.add({
        'date': dayDate.toIso8601String(),
        'data': dayData,
      });
    }
    
    final inventorySummary = await _getInventorySummary();
    final financialSummary = await _getFinancialSummary(startOfWeek, endOfWeek);
    
    final reportData = {
      'week': '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}',
      'dailyReports': dailyReports,
      'inventory': inventorySummary,
      'financial': financialSummary,
      'summary': {
        'totalWeeklySales': dailyReports.fold<double>(0.0, (sum, day) => sum + (day['data']['totalAmount'] ?? 0.0)),
        'averageDailySales': dailyReports.isEmpty ? 0.0 : dailyReports.fold<double>(0.0, (sum, day) => sum + (day['data']['totalAmount'] ?? 0.0)) / dailyReports.length,
        'bestDay': dailyReports.isNotEmpty ? dailyReports.reduce((a, b) => 
            (a['data']['totalAmount'] ?? 0.0) > (b['data']['totalAmount'] ?? 0.0) ? a : b) : null,
        'totalRevenue': financialSummary['totalIncome'] ?? 0.0,
        'totalExpenses': financialSummary['totalExpense'] ?? 0.0,
        'netProfit': (financialSummary['totalIncome'] ?? 0.0) - (financialSummary['totalExpense'] ?? 0.0),
      },
    };
    
    final report = Report(
      id: '',
      title: 'التقرير الأسبوعي - ${_formatDate(startOfWeek)}',
      type: 'weekly',
      startDate: startOfWeek,
      endDate: endOfWeek,
      data: reportData,
      generatedAt: DateTime.now(),
      generatedBy: userId,
      notes: 'تقرير أسبوعي شامل مع تفصيل يومي',
    );
    
    await saveReport(report);
    
    return reportData;
  }

  // Generate Monthly Report
  Future<Map<String, dynamic>> generateMonthlyReport(int year, int month, String userId) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final salesSummary = await _getSalesSummary(startOfMonth, endOfMonth);
    final inventorySummary = await _getInventorySummary();
    final financialSummary = await _getFinancialSummary(startOfMonth, endOfMonth);
    
    // Get weekly breakdown
    final weeklyBreakdown = <Map<String, dynamic>>[];
    final current = DateTime(year, month, 1);
    
    while (current.isBefore(endOfMonth) || current.day == endOfMonth.day) {
      final weekStart = current.subtract(Duration(days: current.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6)).add(const Duration(hours: 23, minutes: 59, seconds: 59));
      
      if (weekStart.isAfter(startOfMonth)) {
        final weekEndDate = weekEnd.isAfter(endOfMonth) ? endOfMonth : weekEnd;
        final weekSummary = await _getSalesSummary(weekStart, weekEndDate);
        
        weeklyBreakdown.add({
          'weekStart': weekStart.toIso8601String(),
          'weekEnd': weekEndDate.toIso8601String(),
          'data': weekSummary,
        });
      }
      
      current.add(const Duration(days: 7));
    }
    
    final reportData = {
      'month': '$year-$month',
      'sales': salesSummary,
      'inventory': inventorySummary,
      'financial': financialSummary,
      'weeklyBreakdown': weeklyBreakdown,
      'summary': {
        'totalMonthlySales': salesSummary['totalAmount'] ?? 0.0,
        'totalTransactions': salesSummary['totalCount'] ?? 0,
        'averageDailySales': salesSummary['totalAmount'] != null ? (salesSummary['totalAmount']! / DateTime(year, month + 1, 0).day) : 0.0,
        'topProducts': salesSummary['topProducts'] ?? [],
        'totalRevenue': financialSummary['totalIncome'] ?? 0.0,
        'totalExpenses': financialSummary['totalExpense'] ?? 0.0,
        'netProfit': (financialSummary['totalIncome'] ?? 0.0) - (financialSummary['totalExpense'] ?? 0.0),
      },
    };
    
    final report = Report(
      id: '',
      title: 'التقرير الشهري - ${_formatMonth(year, month)}',
      type: 'monthly',
      startDate: startOfMonth,
      endDate: endOfMonth,
      data: reportData,
      generatedAt: DateTime.now(),
      generatedBy: userId,
      notes: 'تقرير شهري شامل مع تفصيل أسبوعي',
    );
    
    await saveReport(report);
    
    return reportData;
  }

  // Save Report
  Future<String> saveReport(Report report) async {
    try {
      final docRef = await reportsCollection.add(report.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('فشل في حفظ التقرير: $e');
    }
  }

  // Get Reports
  Stream<List<Report>> getAllReports() {
    return reportsCollection
        .orderBy('generatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Report(
                id: doc.id,
                title: data['title'] ?? '',
                type: data['type'] ?? '',
                startDate: (data['startDate'] as Timestamp).toDate(),
                endDate: (data['endDate'] as Timestamp).toDate(),
                data: data['data'] ?? {},
                generatedAt: (data['generatedAt'] as Timestamp).toDate(),
                generatedBy: data['generatedBy'] ?? '',
                notes: data['notes'],
              );
            })
            .toList());
  }

  // Get Report by ID
  Future<Report?> getReport(String reportId) async {
    try {
      final doc = await reportsCollection.doc(reportId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Report(
          id: doc.id,
          title: data['title'] ?? '',
          type: data['type'] ?? '',
          startDate: (data['startDate'] as Timestamp).toDate(),
          endDate: (data['endDate'] as Timestamp).toDate(),
          data: data['data'] ?? {},
          generatedAt: (data['generatedAt'] as Timestamp).toDate(),
          generatedBy: data['generatedBy'] ?? '',
          notes: data['notes'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب التقرير: $e');
    }
  }

  // Get Sales Summary
  Future<Map<String, dynamic>> _getSalesSummary(DateTime startDate, DateTime endDate) async {
    final transactions = await FirebaseFirestore.instance
        .collection('transactions')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    
    double totalAmount = 0.0;
    int totalCount = 0;
    final Map<String, double> productSales = {};
    final Map<String, int> hourlySales = {};
    
    for (var doc in transactions.docs) {
      final transaction = Transaction.fromFirestore(doc);
      totalAmount += transaction.totalAmount;
      totalCount++;
      
      // Track hourly sales
      final hour = transaction.timestamp.hour;
      hourlySales[hour.toString()] = (hourlySales[hour.toString()] ?? 0) + 1;
      
      // Track product sales
      for (var item in transaction.items) {
        productSales[item.productName] = (productSales[item.productName] ?? 0.0) + (item.price * item.quantity);
      }
    }
    
    // Sort products by sales amount
    final topProducts = productSales.entries
        .map((entry) => {
              'productName': entry.key,
              'totalSales': entry.value,
            })
        .toList()
      ..sort((a, b) => b['totalSales'].compareTo(a['totalSales']));
    
    return {
      'totalAmount': totalAmount,
      'totalCount': totalCount,
      'averageAmount': totalCount > 0 ? totalAmount / totalCount : 0.0,
      'topProducts': topProducts.take(10).toList(),
      'hourlySales': hourlySales,
    };
  }

  // Get Inventory Summary
  Future<Map<String, dynamic>> _getInventorySummary() async {
    final products = await FirebaseFirestore.instance
        .collection('products')
        .where('isActive', isEqualTo: true)
        .get();
    
    int totalProducts = 0;
    int lowStockProducts = 0;
    int outOfStockProducts = 0;
    double totalInventoryValue = 0.0;
    final Map<String, int> categoryStock = {};
    
    for (var doc in products.docs) {
      final product = Product.fromFirestore(doc);
      totalProducts++;
      
      if (product.stock <= 0) {
        outOfStockProducts++;
      } else if (product.stock <= product.minStock) {
        lowStockProducts++;
      }
      
      totalInventoryValue += product.price * product.stock;
      
      final category = product.categoryId;
      categoryStock[category] = (categoryStock[category] ?? 0) + product.stock;
    }
    
    return {
      'totalProducts': totalProducts,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'totalInventoryValue': totalInventoryValue,
      'categoryStock': categoryStock,
    };
  }

  // Get Financial Summary
  Future<Map<String, dynamic>> _getFinancialSummary(DateTime startDate, DateTime endDate) async {
    final transactions = await FirebaseFirestore.instance
        .collection('financial_transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();
    
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final Map<String, double> categorySummary = {};
    
    for (var doc in transactions.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] ?? 0.0).toDouble();
      final type = data['type'] ?? '';
      final category = data['category'] ?? '';
      
      switch (type) {
        case 'income':
          totalIncome += amount;
          break;
        case 'expense':
          totalExpense += amount;
          break;
      }
      
      categorySummary[category] = (categorySummary[category] ?? 0.0) + amount;
    }
    
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netAmount': totalIncome - totalExpense,
      'categorySummary': categorySummary,
    };
  }

  // Format Date
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Format Month
  String _formatMonth(int year, int month) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${months[month - 1]} $year';
  }
}