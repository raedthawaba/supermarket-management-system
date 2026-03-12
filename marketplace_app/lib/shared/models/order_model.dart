import 'package:equatable/equatable.dart';

class OrderItem extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double productPrice;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.productPrice,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productImage: json['product_image'],
      productPrice: (json['product_price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, productId, quantity];
}

class Order extends Equatable {
  final int id;
  final String orderNumber;
  final int customerId;
  final int storeId;
  final int? addressId;

  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double tax;
  final double total;

  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final String? notes;
  final String? cancelReason;

  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? deliveredAt;

  final List<OrderItem> items;
  final Map<String, dynamic>? store;
  final Map<String, dynamic>? delivery;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.storeId,
    this.addressId,
    required this.subtotal,
    this.discount = 0.0,
    required this.deliveryFee,
    this.tax = 0.0,
    required this.total,
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.status,
    this.notes,
    this.cancelReason,
    required this.createdAt,
    this.acceptedAt,
    this.deliveredAt,
    this.items = const [],
    this.store,
    this.delivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      customerId: json['customer_id'] ?? 0,
      storeId: json['store_id'] ?? 0,
      addressId: json['address_id'],
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'cash',
      paymentStatus: json['payment_status'] ?? 'pending',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      cancelReason: json['cancel_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'])
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'])
          : null,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e))
          .toList() ?? [],
      store: json['store'],
      delivery: json['delivery'],
    );
  }

  // Order Status Helpers
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isPreparing => status == 'preparing';
  bool get isReady => status == 'ready_for_pickup';
  bool get isOutForDelivery => status == 'out_for_delivery';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'بانتظار التأكيد';
      case 'accepted':
        return 'تم القبول';
      case 'preparing':
        return 'قيد التجهيز';
      case 'ready_for_pickup':
        return 'جاهز للاستلام';
      case 'out_for_delivery':
        return 'في الطريق';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  List<Object?> get props => [id, orderNumber, status];
}
