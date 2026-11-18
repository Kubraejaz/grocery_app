// lib/services/admin_service.dart
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class AdminService {
  final _db = Supabase.instance.client;

  // ── 1. Image Upload to Supabase Storage ────────────────────
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final ext = fileName.split('.').last;
    final uniqueName = '${const Uuid().v4()}.$ext';
    final path = 'products/$uniqueName';

    await _db.storage
        .from(StorageBuckets.productImages)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    final publicUrl = _db.storage
        .from(StorageBuckets.productImages)
        .getPublicUrl(path);

    return publicUrl;
  }

  // ── 2. Product Management (CRUD) ───────────────────────────
  Future<List<Product>> fetchAllProducts({String? search}) async {
    var q = _db
        .from(Tables.products)
        .select('*, categories(name)');

    if (search != null && search.trim().isNotEmpty) {
      q = q.ilike('name', '%${search.trim()}%');
    }

    final res = await q.order('created_at', ascending: false);
    return (res as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<void> createProduct({
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String imageUrl,
    required String categoryId,
    required int stock,
    required String unit,
    bool isFeatured = false,
  }) async {
    await _db.from(Tables.products).insert({
      'name':           name,
      'description':    description,
      'price':          price,
      'discount_price': discountPrice,
      'image_url':      imageUrl,
      'category_id':    categoryId,
      'stock':          stock,
      'unit':           unit,
      'is_featured':    isFeatured,
      'is_active':      true,
    });
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required String imageUrl,
    required String categoryId,
    required int stock,
    required String unit,
    required bool isFeatured,
    required bool isActive,
  }) async {
    await _db.from(Tables.products).update({
      'name':           name,
      'description':    description,
      'price':          price,
      'discount_price': discountPrice,
      'image_url':      imageUrl,
      'category_id':    categoryId,
      'stock':          stock,
      'unit':           unit,
      'is_featured':    isFeatured,
      'is_active':      isActive,
    }).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    // Soft delete by setting is_active = false
    await _db.from(Tables.products).update({'is_active': false}).eq('id', id);
  }

  Future<void> hardDeleteProduct(String id) async {
    await _db.from(Tables.products).delete().eq('id', id);
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _db.from(Tables.products).update({'stock': newStock}).eq('id', productId);
  }

  // ── 3. Orders Management ──────────────────────────────────
  Future<List<Order>> fetchAllOrders({OrderStatus? statusFilter}) async {
    var q = _db
        .from(Tables.orders)
        .select('*, order_items(*, products(name, image_url))');

    if (statusFilter != null) {
      q = q.eq('status', statusFilter.name);
    }

    final res = await q.order('created_at', ascending: false);
    return (res as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _db
        .from(Tables.orders)
        .update({'status': newStatus.name})
        .eq('id', orderId);
  }

  // ── 4. Dashboard Metrics ───────────────────────────────────
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    final productsRes = await _db
        .from(Tables.products)
        .select('id, stock, is_active');
    
    final ordersRes = await _db
        .from(Tables.orders)
        .select('id, total_amount, status');

    final productsList = (productsRes as List);
    final ordersList = (ordersRes as List);

    final totalProducts = productsList.length;
    final lowStockCount = productsList.where((p) => (p['stock'] as int? ?? 0) <= 5).length;
    final totalOrders = ordersList.length;
    final pendingOrders = ordersList.where((o) => o['status'] == 'pending').length;
    
    double revenue = 0.0;
    for (var o in ordersList) {
      if (o['status'] != 'cancelled') {
        revenue += (o['total_amount'] as num?)?.toDouble() ?? 0.0;
      }
    }

    return {
      'totalProducts': totalProducts,
      'lowStockCount': lowStockCount,
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'revenue': revenue,
    };
  }
}

