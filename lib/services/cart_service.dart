// lib/services/cart_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class CartService {
  final _db = Supabase.instance.client;

  String get _uid {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  // ── Fetch cart ────────────────────────────────────────────
  Future<List<CartItem>> fetchCart() async {
    try {
      final res = await _db
          .from(Tables.cartItems)
          .select('*, products(*, categories(name))')
          .eq('user_id', _uid)
          .order('created_at', ascending: false);

      return (res as List).map((e) {
        final p = Product.fromJson(e['products'] as Map<String, dynamic>);
        return CartItem.fromJson(e, p);
      }).toList();
    } catch (e) {
      debugPrint('CartService.fetchCart error: $e');
      rethrow;
    }
  }

  // ── Add item ──────────────────────────────────────────────
  Future<void> addItem(String productId, {int qty = 1}) async {
    try {
      final uid = _uid;

      // Check if item already exists in cart
      final existing = await _db
          .from(Tables.cartItems)
          .select()
          .eq('user_id', uid)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        // Update existing quantity
        final newQty = (existing['quantity'] as int) + qty;
        await _db
            .from(Tables.cartItems)
            .update({'quantity': newQty})
            .eq('id', existing['id'])
            .eq('user_id', uid);
        debugPrint('CartService: updated qty to $newQty for product $productId');
      } else {
        // Insert new cart item
        await _db.from(Tables.cartItems).insert({
          'user_id':    uid,
          'product_id': productId,
          'quantity':   qty,
        });
        debugPrint('CartService: inserted new item for product $productId');
      }
    } catch (e) {
      debugPrint('CartService.addItem error: $e');
      rethrow;
    }
  }

  // ── Update quantity ───────────────────────────────────────
  Future<void> updateQty(String cartItemId, int qty) async {
    try {
      if (qty <= 0) {
        await removeItem(cartItemId);
        return;
      }
      await _db
          .from(Tables.cartItems)
          .update({'quantity': qty})
          .eq('id', cartItemId)
          .eq('user_id', _uid);
    } catch (e) {
      debugPrint('CartService.updateQty error: $e');
      rethrow;
    }
  }

  // ── Remove item ───────────────────────────────────────────
  Future<void> removeItem(String cartItemId) async {
    try {
      await _db
          .from(Tables.cartItems)
          .delete()
          .eq('id', cartItemId)
          .eq('user_id', _uid);
    } catch (e) {
      debugPrint('CartService.removeItem error: $e');
      rethrow;
    }
  }

  // ── Clear entire cart ─────────────────────────────────────
  Future<void> clearCart() async {
    try {
      await _db
          .from(Tables.cartItems)
          .delete()
          .eq('user_id', _uid);
    } catch (e) {
      debugPrint('CartService.clearCart error: $e');
      rethrow;
    }
  }
}