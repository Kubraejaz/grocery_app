// lib/providers/wishlist_provider.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  final _svc = WishlistService();

  List<WishlistItem> _items   = [];
  bool               _loading = false;
  String?            _error;

  List<WishlistItem> get items   => _items;
  bool               get loading => _loading;
  String?            get error   => _error;
  int                get count   => _items.length;

  bool isInWishlist(String productId) =>
      _items.any((i) => i.product.id == productId);

  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  // ── Load wishlist ─────────────────────────────────────────
  Future<void> load() async {
    _setLoading(true);
    try {
      _items = await _svc.fetchWishlist();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Toggle (add if not in wishlist, remove if already in) ─
  Future<void> toggle(Product product) async {
    if (isInWishlist(product.id)) {
      // Optimistic remove
      _items.removeWhere((i) => i.product.id == product.id);
      notifyListeners();
      try {
        await _svc.removeItem(product.id);
      } catch (e) {
        await load(); // rollback on failure
      }
    } else {
      try {
        await _svc.addItem(product.id);
        await load();
      } catch (e) {
        _error = e.toString();
        notifyListeners();
      }
    }
  }

  // ── Remove item ───────────────────────────────────────────
  Future<void> remove(String productId) async {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
    try {
      await _svc.removeItem(productId);
    } catch (e) {
      await load();
    }
  }

  // ── Clear wishlist ────────────────────────────────────────
  void clear() {
    _items = [];
    notifyListeners();
  }
}