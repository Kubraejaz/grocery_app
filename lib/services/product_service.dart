// lib/services/product_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class ProductService {
  final _db = Supabase.instance.client;

  // ── Categories ────────────────────────────────────────────
  Future<List<Category>> fetchCategories() async {
    final res = await _db
        .from(Tables.categories)
        .select()
        .order('name', ascending: true);
    return (res as List).map((e) => Category.fromJson(e)).toList();
  }

  // ── Products (with optional filters) ─────────────────────
  Future<List<Product>> fetchProducts({
    String? categoryId,
    String? search,
    bool    featuredOnly = false,
    int     limit        = 40,
  }) async {
    var q = _db
        .from(Tables.products)
        .select('*, categories(name)')
        .eq('is_active', true);

    if (categoryId != null)                 q = q.eq('category_id', categoryId);
    if (search != null && search.isNotEmpty) q = q.ilike('name', '%$search%');
    if (featuredOnly)                        q = q.eq('is_featured', true);

    final res = await q
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List).map((e) => Product.fromJson(e)).toList();
  }

  // ── Single product ────────────────────────────────────────
  Future<Product?> fetchById(String id) async {
    final res = await _db
        .from(Tables.products)
        .select('*, categories(name)')
        .eq('id', id)
        .maybeSingle();
    return res == null ? null : Product.fromJson(res);
  }

  Future<List<Product>> fetchFeatured() =>
      fetchProducts(featuredOnly: true, limit: 10);

  Future<List<Product>> search(String query) =>
      fetchProducts(search: query);
}