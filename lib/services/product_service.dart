import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/models/category.dart';
import 'package:supermarket_system_phase1/services/firebase_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final FirebaseService _firebaseService = FirebaseService();

  // Product methods
  Stream<List<Product>> getProducts() {
    return _firebaseService.getProducts();
  }

  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) return getProducts();
    return _firebaseService.searchProducts(query);
  }

  Stream<List<Product>> getProductsByCategory(String categoryId) {
    return _firebaseService.getProducts().map((products) => 
      products.where((product) => product.categoryId == categoryId).toList()
    );
  }

  Stream<List<Product>> getLowStockProducts() {
    return _firebaseService.getProducts().map((products) => 
      products.where((product) => product.isLowStock).toList()
    );
  }

  Stream<List<Product>> getOutOfStockProducts() {
    return _firebaseService.getProducts().map((products) => 
      products.where((product) => product.isOutOfStock).toList()
    );
  }

  Future<void> createProduct({
    required String sku,
    required String name,
    required String categoryId,
    required double priceSell,
    required double priceBuy,
    required int stock,
    required int minStock,
    required String unit,
    String? imageUrl,
  }) async {
    try {
      // Validate inputs
      if (sku.trim().isEmpty) throw Exception('رمز المنتج مطلوب');
      if (name.trim().isEmpty) throw Exception('اسم المنتج مطلوب');
      if (priceSell <= 0) throw Exception('سعر البيع يجب أن يكون أكبر من صفر');
      if (priceBuy <= 0) throw Exception('سعر الشراء يجب أن يكون أكبر من صفر');
      if (priceBuy > priceSell) {
        print('تحذير: سعر الشراء أعلى من سعر البيع');
      }
      if (stock < 0) throw Exception('المخزون لا يمكن أن يكون سالب');
      if (minStock < 0) throw Exception('حد إعادة الطلب لا يمكن أن يكون سالب');

      Product product = Product(
        sku: sku.trim(),
        name: name.trim(),
        categoryId: categoryId,
        priceSell: priceSell,
        priceBuy: priceBuy,
        stock: stock,
        minStock: minStock,
        unit: unit,
        imageUrl: imageUrl,
      );

      await _firebaseService.createProduct(product);
    } catch (e) {
      throw Exception('فشل في إنشاء المنتج: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      // Validate inputs
      if (product.name.trim().isEmpty) throw Exception('اسم المنتج مطلوب');
      if (product.priceSell <= 0) throw Exception('سعر البيع يجب أن يكون أكبر من صفر');
      if (product.priceBuy <= 0) throw Exception('سعر الشراء يجب أن يكون أكبر من صفر');
      if (product.stock < 0) throw Exception('المخزون لا يمكن أن يكون سالب');
      if (product.minStock < 0) throw Exception('حد إعادة الطلب لا يمكن أن يكون سالب');

      await _firebaseService.updateProduct(product);
    } catch (e) {
      throw Exception('فشل في تحديث المنتج: $e');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteProduct(productId);
    } catch (e) {
      throw Exception('فشل في حذف المنتج: $e');
    }
  }

  Future<void> updateStock(String productId, int newStock) async {
    try {
      if (newStock < 0) throw Exception('المخزون لا يمكن أن يكون سالب');
      
      await _firebaseService.updateProductStock(productId, newStock);
    } catch (e) {
      throw Exception('فشل في تحديث المخزون: $e');
    }
  }

  Future<void> increaseStock(String productId, int quantity) async {
    try {
      if (quantity <= 0) throw Exception('الكمية يجب أن تكون أكبر من صفر');
      
      final products = await _firebaseService.getProducts().first;
      final product = products.firstWhere((p) => p.id == productId);
      
      await _firebaseService.updateProductStock(productId, product.stock + quantity);
    } catch (e) {
      throw Exception('فشل في زيادة المخزون: $e');
    }
  }

  Future<void> decreaseStock(String productId, int quantity) async {
    try {
      if (quantity <= 0) throw Exception('الكمية يجب أن تكون أكبر من صفر');
      
      final products = await _firebaseService.getProducts().first;
      final product = products.firstWhere((p) => p.id == productId);
      
      if (product.stock - quantity < 0) {
        throw Exception('المخزون المتاح لا يكفي. المخزون الحالي: ${product.stock}');
      }
      
      await _firebaseService.updateProductStock(productId, product.stock - quantity);
    } catch (e) {
      throw Exception('فشل في تقليل المخزون: $e');
    }
  }

  // Category methods
  Stream<List<Category>> getCategories() {
    return _firebaseService.getCategories();
  }

  Future<void> createCategory({
    required String name,
    String? description,
    String? iconUrl,
  }) async {
    try {
      if (name.trim().isEmpty) throw Exception('اسم الفئة مطلوب');

      Category category = Category(
        name: name.trim(),
        description: description?.trim(),
        iconUrl: iconUrl,
      );

      await _firebaseService.createCategory(category);
    } catch (e) {
      throw Exception('فشل في إنشاء الفئة: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      if (category.name.trim().isEmpty) throw Exception('اسم الفئة مطلوب');

      await _firebaseService.updateCategory(category);
    } catch (e) {
      throw Exception('فشل في تحديث الفئة: $e');
    }
  }

  // Utility methods
  String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} ر.ي';
  }

  String getStockStatus(Product product) {
    if (product.isOutOfStock) return 'نفد';
    if (product.isLowStock) return 'مخزون منخفض';
    return 'متوفر';
  }

  Color getStockStatusColor(Product product) {
    if (product.isOutOfStock) return Color(0xFFF44336); // Red
    if (product.isLowStock) return Color(0xFFFF9800); // Orange
    return Color(0xFF4CAF50); // Green
  }

  double calculateProfit(Product product, int quantity) {
    return (product.priceSell - product.priceBuy) * quantity;
  }

  double calculateProfitPercentage(Product product) {
    if (product.priceBuy == 0) return 0;
    return ((product.priceSell - product.priceBuy) / product.priceBuy) * 100;
  }

  // Search and filter products
  Future<List<Product>> searchProductsSync(String query) async {
    final products = await getProducts().first;
    if (query.trim().isEmpty) return products;
    
    query = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(query) ||
             product.sku.toLowerCase().contains(query);
    }).toList();
  }

  Future<List<Product>> filterProductsByStockRange(int minStock, int maxStock) async {
    final products = await getProducts().first;
    return products.where((product) {
      return product.stock >= minStock && product.stock <= maxStock;
    }).toList();
  }
}