import 'dart:math' as math;
import 'package:supermarket_system_phase1/models/transaction.dart';
import 'package:supermarket_system_phase1/models/cart.dart';
import 'package:supermarket_system_phase1/services/firebase_service.dart';
import 'package:supermarket_system_phase1/constants/app_constants.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final FirebaseService _firebaseService = FirebaseService();

  // Transaction methods
  Stream<List<Transaction>> getTransactions({int limit = 50}) {
    return _firebaseService.getTransactions(limit: limit);
  }

  Stream<List<Transaction>> getTodayTransactions() {
    return _firebaseService.getTodayTransactions();
  }

  Stream<List<Transaction>> getTransactionsByType(String type, {int limit = 50}) {
    return _firebaseService.getTransactions(limit: limit).map((transactions) => 
      transactions.where((transaction) => transaction.type == type).toList()
    );
  }

  Stream<List<Transaction>> getSalesTransactions({int limit = 50}) {
    return getTransactionsByType(AppConstants.transactionSale, limit: limit);
  }

  Stream<List<Transaction>> getPurchaseTransactions({int limit = 50}) {
    return getTransactionsByType(AppConstants.transactionPurchase, limit: limit);
  }

  // Create sale transaction
  Future<void> createSaleTransaction({
    required ShoppingCart cart,
    required String userId,
    required String userName,
    required String paymentMethod,
    double discountAmount = 0.0,
    double discountPercent = 0.0,
    String? notes,
  }) async {
    try {
      // Validate cart
      if (cart.isEmpty) {
        throw Exception('السلة فارغة');
      }

      // Validate payment method
      if (!['cash', 'card', 'bank'].contains(paymentMethod)) {
        throw Exception('طريقة دفع غير صحيحة');
      }

      // Create transaction items
      List<TransactionItem> items = cart.items.map((cartItem) {
        return TransactionItem(
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          quantity: cartItem.quantity,
          price: cartItem.product.priceSell,
          cost: cartItem.product.priceBuy,
          total: cartItem.total,
        );
      }).toList();

      // Calculate totals
      double subtotal = cart.subtotal;
      double discount = discountAmount + ((subtotal * discountPercent) / 100);
      double total = cart.total;
      double tax = 0.0; // For now, no tax
      double netTotal = total + tax;

      // Create transaction
      Transaction sale = Transaction(
        type: AppConstants.transactionSale,
        items: items,
        total: subtotal,
        discount: discount,
        tax: tax,
        netTotal: netTotal,
        paymentMethod: paymentMethod,
        userId: userId,
        userName: userName,
        notes: notes,
      );

      // Use Firestore transaction to ensure atomicity
      await _firebaseService.completeSaleTransaction(sale);
    } catch (e) {
      throw Exception('فشل في إنشاء عملية البيع: $e');
    }
  }

  // Create purchase transaction
  Future<void> createPurchaseTransaction({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required String userId,
    required String userName,
    String? notes,
  }) async {
    try {
      if (quantity <= 0) throw Exception('الكمية يجب أن تكون أكبر من صفر');
      if (unitPrice <= 0) throw Exception('السعر يجب أن يكون أكبر من صفر');

      TransactionItem item = TransactionItem(
        productId: productId,
        productName: productName,
        quantity: quantity,
        price: unitPrice,
        cost: unitPrice, // For purchase, cost equals price
        total: quantity * unitPrice,
      );

      Transaction purchase = Transaction(
        type: AppConstants.transactionPurchase,
        items: [item],
        total: item.total,
        discount: 0.0,
        tax: 0.0,
        netTotal: item.total,
        paymentMethod: AppConstants.paymentCash, // Default to cash for purchase
        userId: userId,
        userName: userName,
        notes: notes,
      );

      await _firebaseService.createTransaction(purchase);

      // Update product stock
      await _firebaseService.updateProductStock(productId, quantity);
    } catch (e) {
      throw Exception('فشل في إنشاء عملية الشراء: $e');
    }
  }

  // Create return transaction
  Future<void> createReturnTransaction({
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    required String userId,
    required String userName,
    String? notes,
  }) async {
    try {
      if (quantity <= 0) throw Exception('الكمية يجب أن تكون أكبر من صفر');
      if (unitPrice <= 0) throw Exception('السعر يجب أن يكون أكبر من صفر');

      TransactionItem item = TransactionItem(
        productId: productId,
        productName: productName,
        quantity: quantity,
        price: unitPrice,
        cost: unitPrice, // For return, cost equals price
        total: -(quantity * unitPrice), // Negative for return
      );

      Transaction returnTransaction = Transaction(
        type: AppConstants.transactionReturn,
        items: [item],
        total: item.total,
        discount: 0.0,
        tax: 0.0,
        netTotal: item.total,
        paymentMethod: AppConstants.paymentCash, // Default to cash for return
        userId: userId,
        userName: userName,
        notes: notes,
      );

      await _firebaseService.createTransaction(returnTransaction);

      // Update product stock (increase for returns)
      // Note: This would need to fetch current stock first
      // For simplicity, we'll just use the basic update
      // In production, use batch operations for safety
    } catch (e) {
      throw Exception('فشل في إنشاء عملية الإرجاع: $e');
    }
  }

  // Analytics methods
  Stream<double> getTotalSalesToday() {
    return getTodayTransactions().map((transactions) {
      return transactions
          .where((t) => t.type == AppConstants.transactionSale)
          .fold(0.0, (sum, t) => sum + t.netTotal);
    });
  }

  Stream<int> getSalesCountToday() {
    return getTodayTransactions().map((transactions) {
      return transactions
          .where((t) => t.type == AppConstants.transactionSale)
          .length;
    });
  }

  Stream<double> getTotalProfitToday() {
    return getTodayTransactions().map((transactions) {
      return transactions
          .where((t) => t.type == AppConstants.transactionSale)
          .fold(0.0, (sum, t) => sum + t.profit);
    });
  }

  // Get sales by payment method
  Stream<Map<String, double>> getSalesByPaymentMethodToday() {
    return getTodayTransactions().map((transactions) {
      Map<String, double> sales = {'cash': 0.0, 'card': 0.0, 'bank': 0.0};
      
      transactions.where((t) => t.type == AppConstants.transactionSale).forEach((t) {
        sales[t.paymentMethod] = (sales[t.paymentMethod] ?? 0.0) + t.netTotal;
      });
      
      return sales;
    });
  }

  // Utility methods
  String formatTransactionType(String type) {
    switch (type) {
      case AppConstants.transactionSale:
        return 'بيع';
      case AppConstants.transactionPurchase:
        return 'شراء';
      case AppConstants.transactionReturn:
        return 'إرجاع';
      case AppConstants.transactionExpense:
        return 'مصروف';
      default:
        return type;
    }
  }

  String formatPaymentMethod(String method) {
    switch (method) {
      case AppConstants.paymentCash:
        return 'نقدي';
      case AppConstants.paymentCard:
        return 'بطاقة';
      case AppConstants.paymentBank:
        return 'تحويل بنكي';
      default:
        return method;
    }
  }

  String formatTransactionStatus(String status) {
    switch (status) {
      case AppConstants.statusCompleted:
        return 'مكتمل';
      case AppConstants.statusPending:
        return 'معلق';
      case AppConstants.statusCancelled:
        return 'ملغي';
      default:
        return status;
    }
  }

  Color getTransactionTypeColor(String type) {
    switch (type) {
      case AppConstants.transactionSale:
        return Color(0xFF4CAF50); // Green
      case AppConstants.transactionPurchase:
        return Color(0xFF2196F3); // Blue
      case AppConstants.transactionReturn:
        return Color(0xFFFF9800); // Orange
      case AppConstants.transactionExpense:
        return Color(0xFFF44336); // Red
      default:
        return Color(0xFF757575); // Gray
    }
  }

  Color getPaymentMethodColor(String method) {
    switch (method) {
      case AppConstants.paymentCash:
        return Color(0xFF4CAF50); // Green
      case AppConstants.paymentCard:
        return Color(0xFF2196F3); // Blue
      case AppConstants.paymentBank:
        return Color(0xFF9C27B0); // Purple
      default:
        return Color(0xFF757575); // Gray
    }
  }
}