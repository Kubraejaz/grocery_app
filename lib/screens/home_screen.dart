// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/category_chip.dart';
import '../widgets/featured_banner.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl  = TextEditingController();
  bool  _showSearch  = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    final pp = context.read<ProductProvider>();
    if (val.isEmpty) {
      pp.clearSearch();
    } else if (val.length >= 2) {
      pp.search(val);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final cart     = context.watch<CartProvider>();

    final selCatName = products.selCatId == null
        ? 'All Products'
        : (products.categories
            .where((c) => c.id == products.selCatId)
            .isNotEmpty
            ? products.categories
                .firstWhere((c) => c.id == products.selCatId)
                .name
            : 'Products');

    return Scaffold(
      backgroundColor: AppTheme.background,

      // ── AppBar ──────────────────────────────────────────
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller:  _searchCtrl,
                autofocus:   true,
                onChanged:   _onSearchChanged,
                style:       const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration:  const InputDecoration(
                  hintText:        'Search groceries...',
                  hintStyle:       TextStyle(color: Colors.white60),
                  border:          InputBorder.none,
                  enabledBorder:   InputBorder.none,
                  focusedBorder:   InputBorder.none,
                  fillColor:       Colors.transparent,
                  contentPadding:  EdgeInsets.zero,
                ),
              )
            : const Text('Grocery App'),
        actions: [
          // Search toggle
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _showSearch = !_showSearch);
              if (!_showSearch) {
                _searchCtrl.clear();
                context.read<ProductProvider>().clearSearch();
              }
            },
          ),

          // Cart with badge
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cart.totalCount > 0)
                Positioned(
                  right: 6,
                  top:   6,
                  child: Container(
                    width:  18,
                    height: 18,
                    decoration: BoxDecoration(
                      color:        AppTheme.accent,
                      shape:        BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '${cart.totalCount > 9 ? '9+' : cart.totalCount}',
                        style: const TextStyle(
                          fontSize:   9,
                          color:      Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Profile
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────
      body: RefreshIndicator(
        onRefresh: () => products.refresh(),
        color:     AppTheme.primary,
        child: CustomScrollView(
          slivers: [

            // Greeting
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${auth.userName} 👋',
                      style: const TextStyle(
                        fontSize:   22,
                        fontWeight: FontWeight.bold,
                        color:      AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'What would you like to buy today?',
                      style: TextStyle(
                        fontSize: 14,
                        color:    AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Featured banner
            if (products.featured.isNotEmpty && !_showSearch)
              SliverToBoxAdapter(
                child: FeaturedBanner(products: products.featured),
              ),

            if (products.featured.isNotEmpty && !_showSearch)
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Category chips
            if (products.categories.isNotEmpty && !_showSearch)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      CategoryChip(
                        label:      'All',
                        isSelected: products.selCatId == null,
                        onTap:      () => products.selectCategory(null),
                      ),
                      ...products.categories.map(
                        (c) => CategoryChip(
                          label:      c.name,
                          isSelected: products.selCatId == c.id,
                          onTap:      () => products.selectCategory(c.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showSearch ? 'Search Results' : selCatName,
                      style: const TextStyle(
                        fontSize:   18,
                        fontWeight: FontWeight.bold,
                        color:      AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${products.products.length} items',
                      style: const TextStyle(
                        fontSize: 13,
                        color:    AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Product grid / loading / empty
            if (products.loading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child:   CircularProgressIndicator(
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              )
            else if (products.products.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child:   Column(
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size:  72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 16,
                            color:    AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try a different category or search term',
                          style: TextStyle(
                            fontSize: 13,
                            color:    AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => ProductCard(product: products.products[i]),
                    childCount: products.products.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing:  12,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),
          ],
        ),
      ),
    );
  }
}