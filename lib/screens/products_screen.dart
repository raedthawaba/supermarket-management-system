import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supermarket_system_phase1/models/product.dart';
import 'package:supermarket_system_phase1/models/category.dart';
import 'package:supermarket_system_phase1/services/product_service.dart';
import 'package:supermarket_system_phase1/services/auth_service.dart';
import 'package:supermarket_system_phase1/constants/app_colors.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  ProductFilter _currentFilter = ProductFilter.all;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productService = ref.watch(productServiceProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (authService.canManageProducts) ...[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddProductDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => _showAddCategoryDialog(),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchAndFilterSection(productService),
          
          // Products List
          Expanded(
            child: _buildProductsList(productService),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection(ProductService productService) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'البحث في المنتجات...',
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
              PopupMenuButton<ProductFilter>(
                icon: const Icon(Icons.filter_list),
                onSelected: (filter) {
                  setState(() {
                    _currentFilter = filter;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: ProductFilter.all,
                    child: Text('جميع المنتجات'),
                  ),
                  const PopupMenuItem(
                    value: ProductFilter.lowStock,
                    child: Text('مخزون منخفض'),
                  ),
                  const PopupMenuItem(
                    value: ProductFilter.outOfStock,
                    child: Text('نفد المخزون'),
                  ),
                  const PopupMenuItem(
                    value: ProductFilter.inStock,
                    child: Text('متوفر'),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Category Filter
          StreamBuilder<List<Category>>(
            stream: productService.getCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              final categories = snapshot.data!;
              
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('جميع الفئات'),
                      selected: _selectedCategoryId == null,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = null;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductService productService) {
    Stream<List<Product>> productsStream;
    
    if (_searchQuery.isNotEmpty) {
      productsStream = productService.searchProducts(_searchQuery);
    } else {
      productsStream = productService.getProducts();
    }

    return StreamBuilder<List<Product>>(
      stream: productsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'خطأ في تحميل المنتجات',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Product> products = snapshot.data!;
        
        // Apply filters
        products = _applyFilters(products);
        
        // Apply category filter
        if (_selectedCategoryId != null) {
          products = products.where((p) => p.categoryId == _selectedCategoryId).toList();
        }

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد منتجات',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 8),
                Text(
                  'جرب تغيير البحث أو المرشحات',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product, productService);
          },
        );
      },
    );
  }

  Widget _buildProductCard(Product product, ProductService productService) {
    final authService = ref.read(authServiceProvider);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showProductDetailsDialog(product),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                              size: 32,
                            );
                          },
                        )
                      : Icon(
                          Icons.inventory_2,
                          color: AppColors.textSecondary,
                          size: 32,
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الرمز: ${product.sku}',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الوحدة: ${product.unit}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              
              // Stock and Price Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: productService.getStockStatusColor(product).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      productService.getStockStatus(product),
                      style: TextStyle(
                        color: productService.getStockStatusColor(product),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${product.priceSell.toStringAsFixed(2)} ر.ي',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'المخزون: ${product.stock}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              // Action Buttons
              if (authService.canManageProducts) ...[
                const SizedBox(width: 16),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        _showEditProductDialog(product);
                        break;
                      case 'delete':
                        _showDeleteConfirmDialog(product);
                        break;
                      case 'stock_in':
                        _showStockUpdateDialog(product, true);
                        break;
                      case 'stock_out':
                        _showStockUpdateDialog(product, false);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('تعديل'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'stock_in',
                      child: Row(
                        children: [
                          Icon(Icons.add),
                          SizedBox(width: 8),
                          Text('زيادة مخزون'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'stock_out',
                      child: Row(
                        children: [
                          Icon(Icons.remove),
                          SizedBox(width: 8),
                          Text('تقليل مخزون'),
                        ],
                      ),
                    ),
                    if (authService.canDeleteProducts) ...[
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('حذف', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Product> _applyFilters(List<Product> products) {
    switch (_currentFilter) {
      case ProductFilter.all:
        return products;
      case ProductFilter.lowStock:
        return products.where((p) => p.isLowStock).toList();
      case ProductFilter.outOfStock:
        return products.where((p) => p.isOutOfStock).toList();
      case ProductFilter.inStock:
        return products.where((p) => p.stock > 0).toList();
    }
  }

  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final priceSellController = TextEditingController();
    final priceBuyController = TextEditingController();
    final stockController = TextEditingController();
    final minStockController = TextEditingController();
    final unitController = TextEditingController();
    
    String? selectedCategoryId;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'اسم المنتج مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(
                      labelText: 'رمز المنتج (باركود)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'رمز المنتج مطلوب';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceSellController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'سعر البيع',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'سعر البيع مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'أدخل رقم صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: priceBuyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'سعر الشراء',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'سعر الشراء مطلوب';
                            }
                            if (double.tryParse(value) == null) {
                              return 'أدخل رقم صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'المخزون الحالي',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'المخزون مطلوب';
                            }
                            if (int.tryParse(value) == null) {
                              return 'أدخل رقم صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: minStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'حد إعادة الطلب',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'حد إعادة الطلب مطلوب';
                            }
                            if (int.tryParse(value) == null) {
                              return 'أدخل رقم صحيح';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: unitController,
                    decoration: const InputDecoration(
                      labelText: 'الوحدة',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'الوحدة مطلوبة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<Category>>(
                    stream: ref.read(productServiceProvider).getCategories(),
                    builder: (context, snapshot) {
                      final categories = snapshot.data ?? [];
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'الفئة',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedCategoryId,
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          selectedCategoryId = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'اختيار الفئة مطلوب';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              try {
                await ref.read(productServiceProvider).createProduct(
                  sku: skuController.text.trim(),
                  name: nameController.text.trim(),
                  categoryId: selectedCategoryId!,
                  priceSell: double.parse(priceSellController.text),
                  priceBuy: double.parse(priceBuyController.text),
                  stock: int.parse(stockController.text),
                  minStock: int.parse(minStockController.text),
                  unit: unitController.text.trim(),
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إضافة المنتج بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في إضافة المنتج: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(Product product) {
    // Similar implementation to _showAddProductDialog
    // but with pre-filled values
  }

  void _showDeleteConfirmDialog(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المنتج "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(productServiceProvider).deleteProduct(product.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف المنتج'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في حذف المنتج: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showStockUpdateDialog(Product product, bool isIncrease) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isIncrease ? 'زيادة المخزون' : 'تقليل المخزون'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('المخزون الحالي: ${product.stock}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الكمية',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = int.tryParse(controller.text) ?? 0;
              if (quantity <= 0) return;
              
              try {
                if (isIncrease) {
                  await ref.read(productServiceProvider).increaseStock(
                    product.id!,
                    quantity,
                  );
                } else {
                  await ref.read(productServiceProvider).decreaseStock(
                    product.id!,
                    quantity,
                  );
                }
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isIncrease 
                            ? 'تم زيادة المخزون بنجاح'
                            : 'تم تقليل المخزون بنجاح',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في تحديث المخزون: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isIncrease ? 'زيادة' : 'تقليل'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة فئة جديدة'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'اسم الفئة',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              try {
                await ref.read(productServiceProvider).createCategory(
                  name: nameController.text.trim(),
                );
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إضافة الفئة بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في إضافة الفئة: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showProductDetailsDialog(Product product) {
    final productService = ref.read(productServiceProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_not_supported,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              _buildDetailRow('الرمز', product.sku),
              _buildDetailRow('سعر البيع', '${product.priceSell.toStringAsFixed(2)} ر.ي'),
              _buildDetailRow('سعر الشراء', '${product.priceBuy.toStringAsFixed(2)} ر.ي'),
              _buildDetailRow('المخزون', product.stock.toString()),
              _buildDetailRow('حد إعادة الطلب', product.minStock.toString()),
              _buildDetailRow('الوحدة', product.unit),
              _buildDetailRow('الأرباح', '${product.profitPerUnit.toStringAsFixed(2)} ر.ي'),
              _buildDetailRow('نسبة الربح', '${product.profitPercentage.toStringAsFixed(1)}%'),
              const Divider(),
              Text(
                'الحالة: ${productService.getStockStatus(product)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: productService.getStockStatusColor(product),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// Enums
enum ProductFilter {
  all,
  lowStock,
  outOfStock,
  inStock,
}