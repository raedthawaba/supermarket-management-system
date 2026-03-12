import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String? email;
  final String phone;
  final String? username;
  final String fullName;
  final String role;
  final String? avatar;
  final bool isActive;
  final bool isVerified;

  const User({
    required this.id,
    this.email,
    required this.phone,
    this.username,
    required this.fullName,
    required this.role,
    this.avatar,
    this.isActive = true,
    this.isVerified = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'],
      phone: json['phone'] ?? '',
      username: json['username'],
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'customer',
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'username': username,
      'full_name': fullName,
      'role': role,
      'avatar': avatar,
      'is_active': isActive,
      'is_verified': isVerified,
    };
  }

  bool get isCustomer => role == 'customer';
  bool get isVendor => role == 'vendor';
  bool get isDriver => role == 'delivery_agent';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, phone, email, role];
}

class Address extends Equatable {
  final int id;
  final String? label;
  final String address;
  final double? lat;
  final double? long;
  final String? city;
  final String? district;
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? phone;
  final String? instructions;
  final bool isDefault;

  const Address({
    required this.id,
    this.label,
    required this.address,
    this.lat,
    this.long,
    this.city,
    this.district,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.phone,
    this.instructions,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      label: json['label'],
      address: json['address'] ?? '',
      lat: json['lat']?.toDouble(),
      long: json['long']?.toDouble(),
      city: json['city'],
      district: json['district'],
      street: json['street'],
      building: json['building'],
      floor: json['floor'],
      apartment: json['apartment'],
      phone: json['phone'],
      instructions: json['instructions'],
      isDefault: json['is_default'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, address, isDefault];
}
