import 'package:equatable/equatable.dart';

class StoreCategory extends Equatable {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? icon;
  final String? image;

  const StoreCategory({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.icon,
    this.image,
  });

  factory StoreCategory.fromJson(Map<String, dynamic> json) {
    return StoreCategory(
      id: json['id'] ?? 0,
      nameAr: json['name_ar'] ?? '',
      nameEn: json['name_en'],
      icon: json['icon'],
      image: json['image'],
    );
  }

  @override
  List<Object?> get props => [id, nameAr];
}

class Store extends Equatable {
  final int id;
  final int vendorId;
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final String? logo;
  final String? coverImage;
  final String? phone;
  final String? email;
  final String? address;
  final double? lat;
  final double? long;
  final String? city;
  final String? district;
  final String status;
  final bool isOpen;
  final String deliveryType;
  final double deliveryFee;
  final double minOrder;
  final int deliveryTime;
  final double rating;
  final int totalRatings;
  final int totalOrders;

  const Store({
    required this.id,
    required this.vendorId,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    this.logo,
    this.coverImage,
    this.phone,
    this.email,
    this.address,
    this.lat,
    this.long,
    this.city,
    this.district,
    this.status = 'active',
    this.isOpen = true,
    this.deliveryType = 'platform',
    this.deliveryFee = 5.0,
    this.minOrder = 0.0,
    this.deliveryTime = 30,
    this.rating = 5.0,
    this.totalRatings = 0,
    this.totalOrders = 0,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? 0,
      vendorId: json['vendor_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      logo: json['logo'],
      coverImage: json['cover_image'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      city: json['city'],
      district: json['district'],
      status: json['status'] ?? 'active',
      isOpen: json['is_open'] ?? true,
      deliveryType: json['delivery_type'] ?? 'platform',
      deliveryFee: (json['delivery_fee'] ?? 5.0).toDouble(),
      minOrder: (json['min_order'] ?? 0.0).toDouble(),
      deliveryTime: json['delivery_time'] ?? 30,
      rating: (json['rating'] ?? 5.0).toDouble(),
      totalRatings: json['total_ratings'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
