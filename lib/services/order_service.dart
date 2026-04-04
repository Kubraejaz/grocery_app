// lib/services/order_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../utils/constants.dart';

class OrderService {
  final _db  = Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  // ── Place a new order from cart items ─────────────────────
  Future<String> placeOrder({
    required List<CartItem> items,
    required double         total,
    required String         address,
  }) async {
    // 1. Insert order header
    final order = await _db
        .from(Tables.orders)
        .insert({
          'user_id':          _uid,
          'total_amount':     total,
          'status':           'pending',
          'delivery_address': address,
        })
        .select()
        .single();

    final orderId = order['id'] as String;

    // 2. Insert order line items
    await _db.from(Tables.orderItems).insert(
      items
          .map((i) => {
                'order_id':   orderId,
                'product_id': i.product.id,
                'quantity':   i.quantity,
                'unit_price': i.product.salePrice,
                'subtotal':   i.subtotal,
              })
          .toList(),
    );

    return orderId;
  }

  // ── Fetch order history for current user ──────────────────
  Future<List<Order>> fetchOrders() async {
    final res = await _db
        .from(Tables.orders)
        .select('*, order_items(*, products(name, image_url))')
        .eq('user_id', _uid)
        .order('created_at', ascending: false);

    return (res as List).map((e) => Order.fromJson(e)).toList();
  }
}