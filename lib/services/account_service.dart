import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supermarket_system_phase1/models/account.dart';
import 'package:supermarket_system_phase1/models/financial_transaction.dart';

class AccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Accounts
  CollectionReference get accountsCollection => _firestore.collection('accounts');
  
  // Financial Transactions
  CollectionReference get transactionsCollection => _firestore.collection('financial_transactions');

  // Create Account
  Future<String> createAccount(Account account) async {
    try {
      final docRef = await accountsCollection.add(account.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('فشل في إنشاء الحساب: $e');
    }
  }

  // Update Account
  Future<void> updateAccount(Account account) async {
    try {
      await accountsCollection.doc(account.id).update(account.toFirestore());
    } catch (e) {
      throw Exception('فشل في تحديث الحساب: $e');
    }
  }

  // Delete Account
  Future<void> deleteAccount(String accountId) async {
    try {
      await accountsCollection.doc(accountId).delete();
    } catch (e) {
      throw Exception('فشل في حذف الحساب: $e');
    }
  }

  // Get Account by ID
  Future<Account?> getAccount(String accountId) async {
    try {
      final doc = await accountsCollection.doc(accountId).get();
      if (doc.exists) {
        return Account.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('فشل في جلب الحساب: $e');
    }
  }

  // Get All Accounts
  Stream<List<Account>> getAllAccounts() {
    return accountsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Account.fromFirestore(doc))
            .toList());
  }

  // Create Financial Transaction
  Future<String> createFinancialTransaction(FinancialTransaction transaction) async {
    try {
      final docRef = await transactionsCollection.add(transaction.toFirestore());
      
      // Update account balance
      await _updateAccountBalance(
        transaction.accountId,
        transaction.type,
        transaction.amount,
      );
      
      return docRef.id;
    } catch (e) {
      throw Exception('فشل في إنشاء الحركة المالية: $e');
    }
  }

  // Update Financial Transaction
  Future<void> updateFinancialTransaction(FinancialTransaction transaction) async {
    try {
      await transactionsCollection.doc(transaction.id).update(transaction.toFirestore());
    } catch (e) {
      throw Exception('فشل في تحديث الحركة المالية: $e');
    }
  }

  // Delete Financial Transaction
  Future<void> deleteFinancialTransaction(String transactionId, String accountId, double amount, String type) async {
    try {
      // Reverse the balance change first
      await _reverseAccountBalance(accountId, type, amount);
      
      // Then delete the transaction
      await transactionsCollection.doc(transactionId).delete();
    } catch (e) {
      throw Exception('فشل في حذف الحركة المالية: $e');
    }
  }

  // Get Financial Transactions for Account
  Stream<List<FinancialTransaction>> getAccountTransactions(String accountId) {
    return transactionsCollection
        .where('accountId', isEqualTo: accountId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromFirestore(doc))
            .toList());
  }

  // Get Financial Transactions by Date Range
  Stream<List<FinancialTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) {
    return transactionsCollection
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromFirestore(doc))
            .toList());
  }

  // Get Financial Transactions by Type
  Stream<List<FinancialTransaction>> getTransactionsByType(String type) {
    return transactionsCollection
        .where('type', isEqualTo: type)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromFirestore(doc))
            .toList());
  }

  // Get All Financial Transactions
  Stream<List<FinancialTransaction>> getAllTransactions() {
    return transactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromFirestore(doc))
            .toList());
  }

  // Calculate Account Balance
  Future<double> calculateAccountBalance(String accountId) async {
    try {
      final transactions = await transactionsCollection
          .where('accountId', isEqualTo: accountId)
          .get();
      
      double balance = 0.0;
      
      for (var doc in transactions.docs) {
        final transaction = FinancialTransaction.fromFirestore(doc);
        
        switch (transaction.type) {
          case 'income':
            balance += transaction.amount;
            break;
          case 'expense':
            balance -= transaction.amount;
            break;
          case 'transfer':
            // Transfer doesn't affect the total balance, just moves between accounts
            break;
        }
      }
      
      return balance;
    } catch (e) {
      throw Exception('فشل في حساب الرصيد: $e');
    }
  }

  // Update Account Balance
  Future<void> _updateAccountBalance(String accountId, String type, double amount) async {
    try {
      final account = await getAccount(accountId);
      if (account != null) {
        double newBalance = account.currentBalance;
        
        switch (type) {
          case 'income':
            newBalance += amount;
            break;
          case 'expense':
            newBalance -= amount;
            break;
          case 'transfer':
            // Transfer doesn't affect balance in this context
            break;
        }
        
        await updateAccount(account.copyWith(
          currentBalance: newBalance,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      throw Exception('فشل في تحديث رصيد الحساب: $e');
    }
  }

  // Reverse Account Balance (for transaction deletion)
  Future<void> _reverseAccountBalance(String accountId, String type, double amount) async {
    try {
      final account = await getAccount(accountId);
      if (account != null) {
        double newBalance = account.currentBalance;
        
        switch (type) {
          case 'income':
            newBalance -= amount;
            break;
          case 'expense':
            newBalance += amount;
            break;
          case 'transfer':
            break;
        }
        
        await updateAccount(account.copyWith(
          currentBalance: newBalance,
          updatedAt: DateTime.now(),
        ));
      }
    } catch (e) {
      throw Exception('فشل في عكس رصيد الحساب: $e');
    }
  }

  // Get Financial Summary for Period
  Future<Map<String, dynamic>> getFinancialSummary(DateTime startDate, DateTime endDate) async {
    try {
      final transactions = await transactionsCollection
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();
      
      double totalIncome = 0.0;
      double totalExpense = 0.0;
      double netAmount = 0.0;
      
      final Map<String, double> categorySummary = {};
      final Map<String, double> accountSummary = {};
      
      for (var doc in transactions.docs) {
        final transaction = FinancialTransaction.fromFirestore(doc);
        
        switch (transaction.type) {
          case 'income':
            totalIncome += transaction.amount;
            netAmount += transaction.amount;
            break;
          case 'expense':
            totalExpense += transaction.amount;
            netAmount -= transaction.amount;
            break;
          case 'transfer':
            break;
        }
        
        // Category summary
        categorySummary[transaction.category] = 
            (categorySummary[transaction.category] ?? 0.0) + transaction.amount;
        
        // Account summary
        accountSummary[transaction.accountId] = 
            (accountSummary[transaction.accountId] ?? 0.0) + transaction.amount;
      }
      
      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netAmount': netAmount,
        'categorySummary': categorySummary,
        'accountSummary': accountSummary,
        'transactionCount': transactions.docs.length,
      };
    } catch (e) {
      throw Exception('فشل في جلب الملخص المالي: $e');
    }
  }
}