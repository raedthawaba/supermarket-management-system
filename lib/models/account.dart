import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String name;
  final String type; // 'cash', 'bank', 'credit_card'
  final String? bankName;
  final String? accountNumber;
  final String? iban;
  final double currentBalance;
  final double initialBalance;
  final String currency;
  final bool isActive;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.bankName,
    this.accountNumber,
    this.iban,
    required this.currentBalance,
    required this.initialBalance,
    required this.currency,
    required this.isActive,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'cash',
      bankName: data['bankName'],
      accountNumber: data['accountNumber'],
      iban: data['iban'],
      currentBalance: (data['currentBalance'] ?? 0.0).toDouble(),
      initialBalance: (data['initialBalance'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'SAR',
      isActive: data['isActive'] ?? true,
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'iban': iban,
      'currentBalance': currentBalance,
      'initialBalance': initialBalance,
      'currency': currency,
      'isActive': isActive,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Account copyWith({
    String? id,
    String? name,
    String? type,
    String? bankName,
    String? accountNumber,
    String? iban,
    double? currentBalance,
    double? initialBalance,
    String? currency,
    bool? isActive,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      iban: iban ?? this.iban,
      currentBalance: currentBalance ?? this.currentBalance,
      initialBalance: initialBalance ?? this.initialBalance,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get typeDisplayName {
    switch (type) {
      case 'cash':
        return 'النقدي';
      case 'bank':
        return 'بنكي';
      case 'credit_card':
        return 'بطاقة ائتمانية';
      default:
        return 'غير محدد';
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'cash':
        return Icons.monetization_on;
      case 'bank':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }
}