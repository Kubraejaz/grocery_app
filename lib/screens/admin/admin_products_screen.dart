// lib/screens/admin/admin_products_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import 'add_edit_product_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _adminSvc   = AdminService();
  final _searchCtrl = TextEditingController();
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadProducts() {
    setState(() {
      _future = _adminSvc.fetchAllProducts(search: _searchCtrl.text);
    });
  }

  Future<void> _updateStockDialog(Product p) async {
    final ctrl = TextEditingController(text: p.stock.toString());
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Update Stock: ${p.name}'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'New Stock (${p.unit})',
            prefixIcon: const Icon(Icons.inventory),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final newStock = int.tryParse(ctrl.text.trim()) ?? p.stock;
      try {
        await _adminSvc.updateStock(p.id, newStock);
        if (!mounted) return;
        Helpers.showSnack(context, 'Stock updated to $newStock ${p.unit}');
        _loadProducts();
        context.read<ProductProvider>().refresh();
      } catch (e) {
        if (!mounted) return;
        Helpers.showSnack(context, 'Error updating stock: $e', error: true);
      }
    }
  }

  Future<void> _confirmDelete(Product p) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Grocery Item'),
        content: Text('Are you sure you want to remove "${p.name}" from the store?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _adminSvc.deleteProduct(p.id);
        if (!mounted) return;
        Helpers.showSnack(context, '${p.name} removed from store.');
        _loadProducts();
        context.read<ProductProvider>().refresh();
      } catch (e) {
        if (!mounted) return;
        Helpers.showSnack(context, 'Error deleting item: $e', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Grocery Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Grocery Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
          if (res == true) {
            _loadProducts();
          }
        },
      ),
      body: Column(
        children: [
          // ── Search Input ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => _loadProducts(),
              decoration: InputDecoration(
                hintText: 'Search inventory items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadProducts();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Products List ────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 14),
                        const Text('No grocery items found.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Item'),
                          onPressed: () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                            );
                            if (res == true) _loadProducts();
                          },
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadProducts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final isLowStock = p.stock <= 5;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 65,
                                  height: 65,
                                  color: Colors.grey.shade100,
                                  child: p.imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: p.imageUrl,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              const Icon(Icons.image, color: Colors.grey),
                                        )
                                      : const Icon(Icons.shopping_basket, color: AppTheme.primary),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (p.isFeatured)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.shade100,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Featured',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${AppText.currencySymbol} ${p.salePrice.toStringAsFixed(0)} / ${p.unit}',
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _updateStockDialog(p),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isLowStock
                                              ? AppTheme.error.withOpacity(0.12)
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Stock: ${p.stock} ${p.unit} ${isLowStock ? '(Low)' : ''} ✎',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isLowStock ? AppTheme.error : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Actions
                              PopupMenuButton<String>(
                                onSelected: (action) async {
                                  if (action == 'edit') {
                                    final res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddEditProductScreen(product: p),
                                      ),
                                    );
                                    if (res == true) _loadProducts();
                                  } else if (action == 'stock') {
                                    _updateStockDialog(p);
                                  } else if (action == 'delete') {
                                    _confirmDelete(p);
                                  }
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Edit Details'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'stock',
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_shopping_cart, size: 20),
                                        SizedBox(width: 8),
                                        Text('Adjust Stock'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: AppTheme.error, size: 20),
                                        SizedBox(width: 8),
                                        Text('Delete Item', style: TextStyle(color: AppTheme.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

