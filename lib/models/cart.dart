import 'package:supermarket_system_phase1/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  double discountAmount; // Discount amount in currency
  double discountPercent; // Discount percentage (0-100)

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discountAmount = 0.0,
    this.discountPercent = 0.0,
  });

  // Calculate subtotal before discount
  double get subtotal => product.priceSell * quantity;

  // Calculate discount amount (whichever is greater)
  double get appliedDiscount {
    double percentDiscount = (subtotal * discountPercent) / 100;
    return discountAmount > percentDiscount ? discountAmount : percentDiscount;
  }

  // Calculate total after discount
  double get total => subtotal - appliedDiscount;

  // Calculate total profit
  double get profit => (product.priceSell - product.priceBuy) * quantity;

  void addQuantity(int additional) {
    quantity += additional;
    if (quantity < 1) quantity = 1;
  }

  void setQuantity(int newQuantity) {
    if (newQuantity >= 1) {
      quantity = newQuantity;
    }
  }

  void clearDiscount() {
    discountAmount = 0.0;
    discountPercent = 0.0;
  }

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.product.id == product.id;
  }

  @override
  int get hashCode => product.id.hashCode;
}

class ShoppingCart {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get uniqueItemCount => _items.length;
  
  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalDiscount => _items.fold(0.0, (sum, item) => sum + item.appliedDiscount);
  double get total => _items.fold(0.0, (sum, item) => sum + item.total);
  double get totalProfit => _items.fold(0.0, (sum, item) => sum + item.profit);

  // Add item to cart
  void addItem(Product product, [int quantity = 1]) {
    // Check if item already exists in cart
    for (CartItem item in _items) {
      if (item.product.id == product.id) {
        item.addQuantity(quantity);
        return;
      }
    }
    // Add new item if not found
    _items.add(CartItem(product: product, quantity: quantity));
  }

  // Remove item from cart
  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
  }

  // Update quantity
  void updateQuantity(String productId, int quantity) {
    for (CartItem item in _items) {
      if (item.product.id == productId) {
        item.setQuantity(quantity);
        if (quantity <= 0) {
          removeItem(productId);
        }
        return;
      }
    }
  }

  // Apply discount to specific item
  void applyDiscount(String productId, {double amount = 0.0, double percent = 0.0}) {
    for (CartItem item in _items) {
      if (item.product.id == productId) {
        item.discountAmount = amount;
        item.discountPercent = percent;
        return;
      }
    }
  }

  // Clear discount from specific item
  void clearDiscount(String productId) {
    for (CartItem item in _items) {
      if (item.product.id == productId) {
        item.clearDiscount();
        return;
      }
    }
  }

  // Clear all items from cart
  void clear() {
    _items.clear();
  }

  // Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  // Check if product is in cart
  bool containsProduct(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get cart item by product ID
  CartItem? getCartItem(String productId) {
    try {
      return _items.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ShoppingCart(items: ${_items.length}, total: $total)';
  }
}