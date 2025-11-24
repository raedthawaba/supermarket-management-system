import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/models/cart.dart';
import 'package:supermarket_system_phase1/services/product_service.dart';
import 'package:supermarket_system_phase1/services/transaction_service.dart';
import 'package:supermarket_system_phase1/services/auth_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String _searchQuery = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  double _discountAmount = 0.0;
  double _discountPercent = 0.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        _searchController.text = result.rawContent;
        setState(() {});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل في مسح الباركود'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addToCart(Product product) {
    final cart = ref.read(shoppingCartProvider);
    cart.addItem(product);
    setState(() {});
  }

  void _removeFromCart(String productId) {
    final cart = ref.read(shoppingCartProvider);
    cart.removeItem(productId);
    setState(() {});
  }

  void _updateQuantity(String productId, int quantity) {
    final cart = ref.read(shoppingCartProvider);
    if (quantity > 0) {
      cart.updateQuantity(productId, quantity);
    } else {
      cart.removeItem(productId);
    }
    setState(() {});
  }

  Future<void> _processSale() async {
    final cart = ref.read(shoppingCartProvider);
    final authService = ref.read(authServiceProvider);
    
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('السلة فارغة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPaymentMethod == PaymentMethod.cash && 
        _discountAmount <= 0 && _discountPercent <= 0) {
      // Validate cash payment with discount if any
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final transactionService = ref.read(transactionServiceProvider);
      
      await transactionService.createSaleTransaction(
        cart: cart,
        userId: authService.currentUser!.uid,
        userName: authService.currentUser!.name,
        paymentMethod: _selectedPaymentMethod.toString(),
        discountAmount: _discountAmount,
        discountPercent: _discountPercent,
        notes: _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() 
            : null,
      );

      // Clear cart and reset
      cart.clear();
      _discountController.clear();
      _notesController.clear();
      _discountAmount = 0.0;
      _discountPercent = 0.0;
      
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم بيع المنتجات بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في البيع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = ref.watch(productServiceProvider);
    final cart = ref.watch(shoppingCartProvider);

    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Products
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'البحث عن منتج (اسم أو رمز)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _scanBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Products Grid
                Expanded(
                  child: _buildProductsGrid(productService),
                ),
              ],
            ),
          ),
          
          // Right Panel - Cart and Checkout
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                left: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              children: [
                // Cart Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'سلة التسوق (${cart.itemCount})',
                          style: AppTextStyles.heading2,
                        ),
                      ),
                      if (cart.itemCount > 0)
                        IconButton(
                          onPressed: () => cart.clear(),
                          icon: const Icon(Icons.clear_all),
                          tooltip: 'مسح السلة',
                        ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Cart Items
                Expanded(
                  child: _buildCartItems(),
                ),
                
                // Checkout Section
                if (cart.itemCount > 0) _buildCheckoutSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(ProductService productService) {
    return StreamBuilder<List<Product>>(
      stream: productService.searchProducts(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('خطأ في تحميل المنتجات'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data!;
        
        if (products.isEmpty) {
          return const Center(child: Text('لا توجد منتجات'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    final cart = ref.read(shoppingCartProvider);
    final cartItem = cart.getCartItem(product.id!);
    final inCart = cartItem != null;

    return Card(
      child: InkWell(
        onTap: () => _addToCart(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textSecondary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.inventory_2,
                            color: AppColors.textSecondary,
                            size: 32,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              // Product Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رصيد: ${product.stock}',
                      style: AppTextStyles.caption.copyWith(
                        color: product.isOutOfStock ? Colors.red : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.priceSell.toStringAsFixed(2)} ر.ي',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Add Button
              ElevatedButton(
                onPressed: product.stock > 0 ? () => _addToCart(product) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: inCart ? AppColors.success : AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 32),
                ),
                child: Text(
                  inCart ? '(${cartItem!.quantity})' : 'إضافة',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    final cart = ref.watch(shoppingCartProvider);
    
    if (cart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'السلة فارغة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final item = cart.items[index];
        return _buildCartItem(item);
      },
    );
  }

  Widget _buildCartItem(CartItem cartItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.product.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${cartItem.product.priceSell.toStringAsFixed(2)} ر.ي × ${cartItem.quantity}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Price
                Text(
                  '${cartItem.total.toStringAsFixed(2)} ر.ي',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Quantity Controls
            Row(
              children: [
                IconButton(
                  onPressed: () => _updateQuantity(cartItem.product.id!, cartItem.quantity - 1),
                  icon: const Icon(Icons.remove),
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    foregroundColor: AppColors.error,
                  ),
                ),
                Text(
                  cartItem.quantity.toString(),
                  style: AppTextStyles.heading3,
                ),
                IconButton(
                  onPressed: () => _updateQuantity(cartItem.product.id!, cartItem.quantity + 1),
                  icon: const Icon(Icons.add),
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.success.withOpacity(0.1),
                    foregroundColor: AppColors.success,
                  ),
                ),
                
                const Spacer(),
                
                // Discount Button
                IconButton(
                  onPressed: () => _showDiscountDialog(cartItem.product.id!),
                  icon: const Icon(Icons.local_offer),
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.secondary.withOpacity(0.1),
                    foregroundColor: AppColors.secondary,
                  ),
                ),
                
                IconButton(
                  onPressed: () => _removeFromCart(cartItem.product.id!),
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                    foregroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    final cart = ref.read(shoppingCartProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Discount Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخصم',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'مبلغ الخصم (ر.ي)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _discountAmount = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'نسبة الخصم (%)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _discountPercent = double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Payment Method
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طريقة الدفع',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: PaymentMethod.values.map((method) {
                      return Expanded(
                        child: RadioListTile<PaymentMethod>(
                          value: method,
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentMethod = value!;
                            });
                          },
                          title: Text(_formatPaymentMethod(method)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Total Summary
          Card(
            color: AppColors.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTotalRow('المجموع الفرعي:', cart.subtotal),
                  if (_discountAmount > 0 || _discountPercent > 0) ...[
                    _buildTotalRow('الخصم:', -(_discountAmount + (cart.subtotal * _discountPercent / 100))),
                  ],
                  const Divider(),
                  _buildTotalRow('الإجمالي:', cart.total, isTotal: true),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Complete Sale Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processSale,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'إتمام البيع',
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.heading3.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodyLarge,
          ),
          Text(
            '${amount.toStringAsFixed(2)} ر.ي',
            style: isTotal
                ? AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )
                : AppTextStyles.bodyLarge.copyWith(
                    color: amount < 0 ? AppColors.error : AppColors.textPrimary,
                  ),
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تطبيق خصم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'مبلغ الخصم (ر.ي)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0.0;
                // Apply discount to specific product
                final cart = ref.read(shoppingCartProvider);
                cart.applyDiscount(productId, amount: amount);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'نسبة الخصم (%)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final percent = double.tryParse(value) ?? 0.0;
                // Apply discount to specific product
                final cart = ref.read(shoppingCartProvider);
                cart.applyDiscount(productId, percent: percent);
                setState(() {});
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.card:
        return 'بطاقة';
      case PaymentMethod.bank:
        return 'تحويل';
    }
  }
}

// Enums and Providers
enum PaymentMethod { cash, card, bank }

// Shopping Cart Provider
final shoppingCartProvider = Provider<ShoppingCart>((ref) {
  return ShoppingCart();
});