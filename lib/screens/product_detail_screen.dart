// lib/screens/product_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final p      = widget.product;
    final cart   = context.watch<CartProvider>();
    final inCart = cart.isInCart(p.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero image + AppBar ──────────────────────────
          SliverAppBar(
            expandedHeight: 310,
            pinned:          true,
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.textDark,
            elevation:       0,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${p.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: p.imageUrl,
                      fit:      BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade100,
                        child: const Center(
                            child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      ),
                    ),
                    // Gradient overlay at bottom
                    Positioned(
                      bottom: 0,
                      left:   0,
                      right:  0,
                      child:  Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin:  Alignment.bottomCenter,
                            end:    Alignment.topCenter,
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Product details ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + featured tag
                  Row(
                    children: [
                      _Tag(
                        label: p.categoryName,
                        color: AppTheme.primary,
                      ),
                      if (p.isFeatured) ...[
                        const SizedBox(width: 8),
                        _Tag(
                          label: '⭐ Featured',
                          color: AppTheme.accent,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Product name
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize:   24,
                      fontWeight: FontWeight.bold,
                      color:      AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Unit + stock row
                  Row(
                    children: [
                      const Icon(Icons.straighten_outlined,
                          size: 16, color: AppTheme.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Per ${p.unit}',
                        style: const TextStyle(
                          color:   AppTheme.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.isInStock
                              ? AppTheme.success.withOpacity(0.1)
                              : AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              p.isInStock
                                  ? Icons.check_circle_outline
                                  : Icons.cancel_outlined,
                              size:  13,
                              color: p.isInStock
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.isInStock
                                  ? '${p.stock} in stock'
                                  : 'Out of stock',
                              style: TextStyle(
                                fontSize:   12,
                                fontWeight: FontWeight.w500,
                                color:      p.isInStock
                                    ? AppTheme.success
                                    : AppTheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating row
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating:      p.rating,
                        itemSize:    20,
                        itemBuilder: (_, __) => const Icon(
                          Icons.star_rounded,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${p.rating.toStringAsFixed(1)} (${p.reviewCount} reviews)',
                        style: const TextStyle(
                          color:   AppTheme.textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline:       TextBaseline.alphabetic,
                    children: [
                      Text(
                        Helpers.formatPrice(p.salePrice),
                        style: const TextStyle(
                          fontSize:   28,
                          fontWeight: FontWeight.bold,
                          color:      AppTheme.primary,
                        ),
                      ),
                      if (p.isOnSale) ...[
                        const SizedBox(width: 10),
                        Text(
                          Helpers.formatPrice(p.price),
                          style: const TextStyle(
                            fontSize:   16,
                            color:      AppTheme.textLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color:        AppTheme.error,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${p.discountPercent.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color:      Colors.white,
                              fontSize:   11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quantity selector
                  if (p.isInStock) ...[
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color:      AppTheme.textDark,
                        fontSize:   15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QtyButton(
                          icon:    Icons.remove_rounded,
                          onTap:   () {
                            if (_qty > 1) setState(() => _qty--);
                          },
                          enabled: _qty > 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child:   Text(
                            '$_qty',
                            style: const TextStyle(
                              fontSize:   20,
                              fontWeight: FontWeight.bold,
                              color:      AppTheme.textDark,
                            ),
                          ),
                        ),
                        _QtyButton(
                          icon:    Icons.add_rounded,
                          onTap:   () {
                            if (_qty < p.stock) setState(() => _qty++);
                          },
                          enabled: _qty < p.stock,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${p.stock} available',
                          style: const TextStyle(
                            color:   AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Divider(),
                  const SizedBox(height: 14),

                  // Description
                  const Text(
                    'Product Description',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.bold,
                      color:      AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description.isEmpty
                        ? 'No description available for this product.'
                        : p.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color:    AppTheme.textMuted,
                      height:   1.7,
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom action bar ──────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset:     const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // View cart (if already in cart)
              if (inCart) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    icon:  const Icon(Icons.shopping_cart_outlined, size: 18),
                    label: const Text('View Cart'),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Add to cart
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: p.isInStock
                      ? () async {
                          for (int i = 0; i < _qty; i++) {
                            await cart.add(p.id);
                          }
                          if (!context.mounted) return;
                          Helpers.showSnack(
                            context,
                            '${p.name} added to cart!',
                          );
                        }
                      : null,
                  icon:  const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  label: Text(inCart ? 'Add More' : 'Add to Cart'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color  color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      color,
            fontSize:   12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool     enabled;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

    @override
    Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: enabled ? onTap : null,
        child: Container(
          width:  36,
          height: 36,
          decoration: BoxDecoration(
            color:        enabled
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled ? AppTheme.primary.withOpacity(0.3) : Colors.grey.shade200,
            ),
          ),
          child: Icon(
            icon,
            size:  18,
            color: enabled ? AppTheme.primary : Colors.grey.shade400,
          ),
        ),
      );
}