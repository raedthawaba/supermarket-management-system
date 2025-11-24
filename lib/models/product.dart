import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String? id;
  final String sku;
  final String name;
  final String categoryId;
  final double priceSell;
  final double priceBuy;
  final int stock;
  final int minStock;
  final String unit;
  final String? imageUrl;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Product({
    this.id,
    required this.sku,
    required this.name,
    required this.categoryId,
    required this.priceSell,
    required this.priceBuy,
    required this.stock,
    required this.minStock,
    required this.unit,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>? ?? {};
    
    return Product(
      id: doc.id,
      sku: data['sku'] ?? '',
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      priceSell: (data['priceSell'] ?? 0.0).toDouble(),
      priceBuy: (data['priceBuy'] ?? 0.0).toDouble(),
      stock: data['stock'] ?? 0,
      minStock: data['minStock'] ?? 0,
      unit: data['unit'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: data['createdAt'] as Timestamp?,
      updatedAt: data['updatedAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sku': sku,
      'name': name,
      'categoryId': categoryId,
      'priceSell': priceSell,
      'priceBuy': priceBuy,
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  double get profitPerUnit => priceSell - priceBuy;
  double get profitPercentage => priceBuy > 0 ? (profitPerUnit / priceBuy) * 100 : 0;
  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock <= 0;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, stock: $stock)';
  }
}