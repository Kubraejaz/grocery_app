// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final _svc = ProductService();

  List<Product>  _products  = [];
  List<Product>  _featured  = [];
  List<Category> _categories = [];
  String?        _selCatId;
  String         _searchQuery = '';
  bool           _loading = false;
  String?        _error;

  // ── Getters ───────────────────────────────────────────────
  List<Product>  get products   => _products;
  List<Product>  get featured   => _featured;
  List<Category> get categories => _categories;
  String?        get selCatId   => _selCatId;
  bool           get loading    => _loading;
  String?        get error      => _error;
  bool           get hasError   => _error != null;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }

  // ── Initial load ──────────────────────────────────────────
  Future<void> init() async {
    _setLoading(true);
    try {
      final res = await Future.wait([
        _svc.fetchCategories(),
        _svc.fetchFeatured(),
        _svc.fetchProducts(),
      ]);
      _categories = res[0] as List<Category>;
      _featured   = res[1] as List<Product>;
      _products   = res[2] as List<Product>;
      _error      = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Reload products only ──────────────────────────────────
  Future<void> _reloadProducts() async {
    _setLoading(true);
    try {
      _products = await _svc.fetchProducts(
        categoryId: _selCatId,
        search:     _searchQuery.isEmpty ? null : _searchQuery,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ── Category filter ───────────────────────────────────────
  void selectCategory(String? id) {
    _selCatId    = id;
    _searchQuery = '';
    _reloadProducts();
  }

  // ── Search ────────────────────────────────────────────────
  Future<void> search(String query) async {
    _searchQuery = query;
    _selCatId    = null;
    await _reloadProducts();
  }

  void clearSearch() {
    _searchQuery = '';
    _reloadProducts();
  }

  // ── Pull-to-refresh ───────────────────────────────────────
  Future<void> refresh() => init();
}