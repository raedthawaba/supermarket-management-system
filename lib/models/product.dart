import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    required String name,
    required String barcode,
    required double price,
    required double cost,
    required int stock,
    required int minStock,
    required CategoryModel category,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    String? imageUrl,
    @Default(true) bool isActive,
    @Default(false) bool isPerishable,
    DateTime? expiryDate,
    String? brand,
    String? unit,
    @Default(0.0) double discount,
    @Default(0) int taxRate,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String color,
    required DateTime createdAt,
    String? description,
    String? icon,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
}

extension ProductModelExtension on ProductModel {
  double get profitMargin {
    return ((price - cost) / price) * 100;
  }

  bool get isLowStock {
    return stock <= minStock;
  }

  double get finalPrice {
    if (discount > 0) {
      return price - (price * discount / 100);
    }
    return price;
  }

  bool get isExpiringSoon {
    if (!isPerishable || expiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = expiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
  }

  bool get isExpired {
    if (!isPerishable || expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}