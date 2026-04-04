// lib/services/cart_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class CartService {
  final _db  = Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  // ── Fetch all cart items for current user ─────────────────
  Future<List<CartItem>> fetchCart() async {
    final res = await _db
        .from(Tables.cartItems)
        .select('*, products(*, categories(name))')
        .eq('user_id', _uid);

    return (res as List).map((e) {
      final p = Product.fromJson(e['products'] as Map<String, dynamic>);
      return CartItem.fromJson(e, p);
    }).toList();
  }

  // ── Add item (or increment if already in cart) ────────────
  Future<void> addItem(String productId, {int qty = 1}) async {
    final existing = await _db
        .from(Tables.cartItems)
        .select()
        .eq('user_id', _uid)
        .eq('product_id', productId)
        .maybeSingle();

    if (existing != null) {
      await _db
          .from(Tables.cartItems)
          .update({'quantity': (existing['quantity'] as int) + qty})
          .eq('id', existing['id']);
    } else {
      await _db.from(Tables.cartItems).insert({
        'user_id':    _uid,
        'product_id': productId,
        'quantity':   qty,
      });
    }
  }

  // ── Update quantity (removes if qty <= 0) ─────────────────
  Future<void> updateQty(String cartItemId, int qty) async {
    if (qty <= 0) {
      await removeItem(cartItemId);
      return;
    }
    await _db
        .from(Tables.cartItems)
        .update({'quantity': qty})
        .eq('id', cartItemId);
  }

  // ── Remove single item ────────────────────────────────────
  Future<void> removeItem(String cartItemId) async =>
      _db.from(Tables.cartItems).delete().eq('id', cartItemId);

  // ── Clear entire cart ─────────────────────────────────────
  Future<void> clearCart() async =>
      _db.from(Tables.cartItems).delete().eq('user_id', _uid);
}