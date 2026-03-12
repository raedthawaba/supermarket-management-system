import 'package:equatable/equatable.dart';

class ProductCategory extends Equatable {
  final int id;
  final int? storeId;
  final String nameAr;
  final String? nameEn;
  final String? icon;
  final String? image;
  final int? parentId;
  final bool isActive;

  const ProductCategory({
    required this.id,
    this.storeId,
    required this.nameAr,
    this.nameEn,
    this.icon,
    this.image,
    this.parentId,
    this.isActive = true,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] ?? 0,
      storeId: json['store_id'],
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'],
      icon: json['icon'],
      image: json['image'],
      parentId: json['parent_id'],
      isActive: json['is_active'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, nameAr];
}

class Product extends Equatable {
  final int id;
  final int storeId;
  final int? categoryId;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String? images;
  final double price;
  final double? originalPrice;
  final int stockQuantity;
  final String? unit;
  final String? sku;
  final String status;
  final bool isFeatured;
  final double rating;
  final int totalRatings;
  final int totalSold;

  const Product({
    required this.id,
    required this.storeId,
    this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.images,
    required this.price,
    this.originalPrice,
    this.stockQuantity = 0,
    this.unit,
    this.sku,
    this.status = 'active',
    this.isFeatured = false,
    this.rating = 5.0,
    this.totalRatings = 0,
    this.totalSold = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      image: json['image'],
      images: json['images'],
      price: (json['price'] ?? 0.0).toDouble(),
      originalPrice: json['original_price']?.toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      unit: json['unit'],
      sku: json['sku'],
      status: json['status'] ?? 'active',
      isFeatured: json['is_featured'] ?? false,
      rating: (json['rating'] ?? 5.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      totalSold: json['total_sold'] ?? 0,
    );
  }

  bool get isAvailable => stockQuantity > 0 && status == 'active';
  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice! * 100);
  }

  @override
  List<Object?> get props => [id, name, price];
}
