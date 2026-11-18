// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final _svc = CartService();

  final List<CartItem> _items = [];
  bool           _loading = false;
  String?        _error;

  // ── Getters ───────────────────────────────────────────────
  List<CartItem> get items   => List.unmodifiable(_items);
  bool           get loading => _loading;
  String?        get error   => _error;

  /// Total count of individual items (sum of quantities)
  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  /// Number of distinct products in cart
  int get distinctCount => _items.length;

  /// Grand total price
  double get totalAmount => _items.fold(0.0, (sum, i) => sum + i.subtotal);

  bool isInCart(String productId) =>
      _items.any((i) => i.product.id == productId);

  int qtyInCart(String productId) {
    final match = _items.where((i) => i.product.id == productId);
    return match.isEmpty ? 0 : match.first.quantity;
  }

  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  // ── Load cart ─────────────────────────────────────────────
  Future<void> load() async {
    _setLoading(true);
    try {
      final remoteItems = await _svc.fetchCart();
      if (remoteItems.isNotEmpty) {
        _items.clear();
        _items.addAll(remoteItems);
      }
      _error = null;
    } catch (e) {
      // In offline / demo mode, preserve existing in-memory cart items
    } finally {
      _setLoading(false);
    }
  }

  // ── Add to cart (Immediate UI update + Async backend sync) ──
  Future<void> add(String productId, [Product? product]) async {
    // 1. Immediately update in-memory list for instant UI feedback
    final existingIndex = _items.indexWhere((i) => i.product.id == productId);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else if (product != null) {
      _items.add(CartItem(
        id: 'cart-${product.id}',
        userId: 'current',
        product: product,
        quantity: 1,
      ));
    }
    notifyListeners();

    // 2. Asynchronously sync to Supabase
    try {
      await _svc.addItem(productId);
    } catch (_) {
      // In demo / presentation mode, in-memory state is preserved!
    }
  }

  // ── Update quantity ───────────────────────────────────────
  Future<void> updateQty(String cartItemId, int qty) async {
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index >= 0) {
      if (qty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = qty;
      }
      notifyListeners();
    }

    try {
      await _svc.updateQty(cartItemId, qty);
    } catch (_) {}
  }

  // ── Remove item ───────────────────────────────────────────
  Future<void> remove(String cartItemId) async {
    _items.removeWhere((i) => i.id == cartItemId);
    notifyListeners();
    try {
      await _svc.removeItem(cartItemId);
    } catch (_) {}
  }

  // ── Clear all ─────────────────────────────────────────────
  Future<void> clear() async {
    _items.clear();
    notifyListeners();
    try {
      await _svc.clearCart();
    } catch (_) {}
  }
}
