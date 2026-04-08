// lib/services/wishlist_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  final _db = Supabase.instance.client;

  String get _uid {
    final user = _db.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  // ── Fetch all wishlist items ──────────────────────────────
  Future<List<WishlistItem>> fetchWishlist() async {
    try {
      final res = await _db
          .from('wishlist_items')
          .select('*, products(*, categories(name))')
          .eq('user_id', _uid)
          .order('created_at', ascending: false);

      return (res as List).map((e) {
        final p = Product.fromJson(e['products'] as Map<String, dynamic>);
        return WishlistItem.fromJson(e, p);
      }).toList();
    } catch (e) {
      debugPrint('WishlistService.fetchWishlist error: $e');
      rethrow;
    }
  }

  // ── Add product to wishlist ───────────────────────────────
  Future<void> addItem(String productId) async {
    try {
      await _db.from('wishlist_items').insert({
        'user_id':    _uid,
        'product_id': productId,
      });
    } catch (e) {
      debugPrint('WishlistService.addItem error: $e');
      rethrow;
    }
  }

  // ── Remove product from wishlist ──────────────────────────
  Future<void> removeItem(String productId) async {
    try {
      await _db
          .from('wishlist_items')
          .delete()
          .eq('user_id', _uid)
          .eq('product_id', productId);
    } catch (e) {
      debugPrint('WishlistService.removeItem error: $e');
      rethrow;
    }
  }
}