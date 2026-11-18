// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/admin_service.dart';
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

      if (_products.isEmpty) {
        _products = _getMockProducts();
        _featured = _products.where((p) => p.isFeatured).toList();
      }
      _mergeSessionProducts();
    } catch (_) {
      // Failsafe fallback so presentation is always populated even offline
      _categories = _getMockCategories();
      _products   = _getMockProducts();
      _featured   = _products.where((p) => p.isFeatured).toList();
      _mergeSessionProducts();
      _error      = null;
    } finally {
      _setLoading(false);
    }
  }

  void _mergeSessionProducts() {
    for (final p in AdminService.sessionAddedProducts) {
      if (!_products.any((x) => x.id == p.id)) {
        _products.insert(0, p);
        if (p.isFeatured && !_featured.any((x) => x.id == p.id)) {
          _featured.insert(0, p);
        }
      }
    }
  }

  void addOptimisticProduct(Product p) {
    _products.removeWhere((x) => x.id == p.id);
    _products.insert(0, p);
    if (p.isFeatured) {
      _featured.removeWhere((x) => x.id == p.id);
      _featured.insert(0, p);
    }
    notifyListeners();
  }

  // ── Reload products only ──────────────────────────────────
  Future<void> _reloadProducts() async {
    _setLoading(true);
    try {
      _products = await _svc.fetchProducts(
        categoryId: _selCatId,
        search:     _searchQuery.isEmpty ? null : _searchQuery,
      );
      if (_products.isEmpty && _searchQuery.isEmpty && _selCatId == null) {
        _products = _getMockProducts();
      }
      _error = null;
    } catch (_) {
      var list = _getMockProducts();
      if (_selCatId != null) {
        list = list.where((p) => p.categoryId == _selCatId).toList();
      }
      if (_searchQuery.isNotEmpty) {
        list = list.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      }
      _products = list;
      _error = null;
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

  // ── Failsafe Mock Data for Presentations ─────────────────
  static List<Category> _getMockCategories() => const [
        Category(id: 'cat-veg', name: 'Vegetables', colorHex: '#4CAF50'),
        Category(id: 'cat-fruit', name: 'Fruits', colorHex: '#FF9800'),
        Category(id: 'cat-dairy', name: 'Dairy & Eggs', colorHex: '#2196F3'),
        Category(id: 'cat-bakery', name: 'Bakery', colorHex: '#795548'),
        Category(id: 'cat-bev', name: 'Beverages', colorHex: '#E91E63'),
      ];

  static List<Product> _getMockProducts() => [
        Product(
          id: 'p-1',
          name: 'Fresh Farm Tomatoes',
          description: 'Locally grown, juicy organic red tomatoes.',
          price: 150,
          discountPrice: 120,
          imageUrl: 'https://images.unsplash.com/photo-1546470427-227c7369a924?w=400',
          categoryId: 'cat-veg',
          categoryName: 'Vegetables',
          stock: 45,
          unit: 'kg',
          rating: 4.8,
          reviewCount: 32,
          isFeatured: true,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 'p-2',
          name: 'Crisp Red Apples',
          description: 'Fresh and crunchy high altitude red apples.',
          price: 260,
          discountPrice: 220,
          imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
          categoryId: 'cat-fruit',
          categoryName: 'Fruits',
          stock: 30,
          unit: 'kg',
          rating: 4.9,
          reviewCount: 48,
          isFeatured: true,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 'p-3',
          name: 'Pure Full Cream Milk',
          description: 'Pasteurized 1-litre fresh dairy milk pouch.',
          price: 180,
          discountPrice: null,
          imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
          categoryId: 'cat-dairy',
          categoryName: 'Dairy & Eggs',
          stock: 60,
          unit: 'litre',
          rating: 4.7,
          reviewCount: 19,
          isFeatured: false,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 'p-4',
          name: 'Whole Grain Artisan Bread',
          description: 'Freshly baked sliced whole wheat bakery loaf.',
          price: 130,
          discountPrice: 110,
          imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
          categoryId: 'cat-bakery',
          categoryName: 'Bakery',
          stock: 25,
          unit: 'piece',
          rating: 4.6,
          reviewCount: 14,
          isFeatured: true,
          createdAt: DateTime.now(),
        ),
        Product(
          id: 'p-5',
          name: 'Fresh Farm Eggs (Dozen)',
          description: 'Grade A organic white farm eggs.',
          price: 240,
          discountPrice: null,
          imageUrl: 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=400',
          categoryId: 'cat-dairy',
          categoryName: 'Dairy & Eggs',
          stock: 40,
          unit: 'dozen',
          rating: 4.9,
          reviewCount: 52,
          isFeatured: false,
          createdAt: DateTime.now(),
        ),
      ];
}