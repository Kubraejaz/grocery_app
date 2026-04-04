// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final _svc = CartService();

  List<CartItem> _items   = [];
  bool           _loading = false;
  String?        _error;

  // ── Getters ───────────────────────────────────────────────
  List<CartItem> get items   => _items;
  bool           get loading => _loading;
  String?        get error   => _error;

  /// Total number of individual items (sum of quantities)
  int get totalCount =>
      _items.fold(0, (sum, i) => sum + i.quantity);

  /// Number of distinct products in cart
  int get distinctCount => _items.length;

  /// Grand total price
  double get totalAmount =>
      _items.fold(0.0, (sum, i) => sum + i.subtotal);

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
      _items = await _svc.fetchCart();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Add to cart ───────────────────────────────────────────
  Future<void> add(String productId) async {
    try {
      await _svc.addItem(productId);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ── Update quantity ───────────────────────────────────────
  Future<void> updateQty(String cartItemId, int qty) async {
    try {
      await _svc.updateQty(cartItemId, qty);
      await load();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ── Remove item ───────────────────────────────────────────
  Future<void> remove(String cartItemId) async {
    _items.removeWhere((i) => i.id == cartItemId);
    notifyListeners();
    try {
      await _svc.removeItem(cartItemId);
    } catch (e) {
      await load(); // rollback on failure
    }
  }

  // ── Clear all ─────────────────────────────────────────────
  Future<void> clear() async {
    try {
      await _svc.clearCart();
      _items = [];
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}