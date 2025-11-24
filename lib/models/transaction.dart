import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double cost;
  final double total;

  TransactionItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.cost,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'cost': cost,
      'total': total,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      cost: (map['cost'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }
}

class Transaction {
  final String? id;
  final String type; // 'sale', 'purchase', 'return', 'expense'
  final List<TransactionItem> items;
  final double total;
  final double discount;
  final double tax;
  final double netTotal;
  final String paymentMethod; // 'cash', 'card', 'bank'
  final String userId;
  final String? userName;
  final Timestamp createdAt;
  final String status; // 'completed', 'pending', 'cancelled'
  final String? notes;

  Transaction({
    this.id,
    required this.type,
    required this.items,
    required this.total,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.netTotal,
    required this.paymentMethod,
    required this.userId,
    this.userName,
    Timestamp? createdAt,
    this.status = 'completed',
    this.notes,
  }) : createdAt = createdAt ?? Timestamp.now();

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>? ?? {};
    List<TransactionItem> items = [];
    
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => TransactionItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }

    return Transaction(
      id: doc.id,
      type: data['type'] ?? '',
      items: items,
      total: (data['total'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      netTotal: (data['netTotal'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'],
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      status: data['status'] ?? 'completed',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'discount': discount,
      'tax': tax,
      'netTotal': netTotal,
      'paymentMethod': paymentMethod,
      'userId': userId,
      'userName': userName,
      'createdAt': createdAt,
      'status': status,
      'notes': notes,
    };
  }

  double get profit {
    double totalCost = items.fold(0.0, (sum, item) => sum + (item.cost * item.quantity));
    return total - totalCost;
  }

  bool get isSale => type == 'sale';
  bool get isPurchase => type == 'purchase';
  bool get isReturn => type == 'return';
  bool get isExpense => type == 'expense';

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, total: $netTotal, status: $status)';
  }
}