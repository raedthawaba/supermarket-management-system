import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialTransaction {
  final String id;
  final String accountId;
  final String type; // 'income', 'expense', 'transfer'
  final String category; // 'sales', 'purchase', 'salary', 'rent', 'utilities', etc.
  final double amount;
  final String description;
  final String? referenceNumber;
  final DateTime date;
  final String? notes;
  final List<String> tags;
  final String status; // 'completed', 'pending', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const FinancialTransaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.category,
    required this.amount,
    required this.description,
    this.referenceNumber,
    required this.date,
    this.notes,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  factory FinancialTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FinancialTransaction(
      id: doc.id,
      accountId: data['accountId'] ?? '',
      type: data['type'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      referenceNumber: data['referenceNumber'],
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'],
      tags: List<String>.from(data['tags'] ?? []),
      status: data['status'] ?? 'completed',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'accountId': accountId,
      'type': type,
      'category': category,
      'amount': amount,
      'description': description,
      'referenceNumber': referenceNumber,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'tags': tags,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'createdBy': createdBy,
    };
  }

  FinancialTransaction copyWith({
    String? id,
    String? accountId,
    String? type,
    String? category,
    double? amount,
    String? description,
    String? referenceNumber,
    DateTime? date,
    String? notes,
    List<String>? tags,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'income':
        return 'دخل';
      case 'expense':
        return 'مصروف';
      case 'transfer':
        return 'تحويل';
      default:
        return 'غير محدد';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'income':
        return Icons.trending_up;
      case 'expense':
        return Icons.trending_down;
      case 'transfer':
        return Icons.swap_horiz;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color get typeColor {
    switch (type) {
      case 'income':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}