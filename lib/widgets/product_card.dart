// lib/widgets/product_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_detail_screen.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart   = context.watch<CartProvider>();
    final inCart = cart.isInCart(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Product image ─────────────────────────────
            Stack(
              children: [
                Hero(
                  tag: 'product-${product.id}',
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    height:   140,
                    width:    double.infinity,
                    fit:      BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 140,
                      color:  Colors.grey.shade100,
                      child:  const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 140,
                      color:  Colors.grey.shade100,
                      child:  const Icon(
                        Icons.image_not_supported_outlined,
                        size:  44,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Sale badge
                if (product.isOnSale)
                  Positioned(
                    top:  8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color:        AppTheme.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Out of stock overlay
                if (!product.isInStock)
                  Positioned.fill(
                    child: Container(
                      color:     Colors.black45,
                      alignment: Alignment.center,
                      child:     Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color:        Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color:      Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:   12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ── Details ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      maxLines:  2,
                      overflow:  TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      AppTheme.textDark,
                        height:     1.3,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Unit label
                    Text(
                      'Per ${product.unit}',
                      style: const TextStyle(
                        fontSize: 11,
                        color:    AppTheme.textLight,
                      ),
                    ),

                    const Spacer(),

                    // Price + add button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Prices
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helpers.formatPrice(product.salePrice),
                                style: const TextStyle(
                                  color:      AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize:   13,
                                ),
                              ),
                              if (product.isOnSale)
                                Text(
                                  Helpers.formatPrice(product.price),
                                  style: const TextStyle(
                                    fontSize:   11,
                                    color:      AppTheme.textLight,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Add-to-cart button
                        GestureDetector(
                          onTap: product.isInStock
                              ? () async {
                                  await cart.add(product.id);
                                  if (!context.mounted) return;
                                  Helpers.showSnack(
                                    context,
                                    '${product.name} added to cart!',
                                  );
                                }
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width:    34,
                            height:   34,
                            decoration: BoxDecoration(
                              color: product.isInStock
                                  ? (inCart
                                      ? AppTheme.primary
                                      : AppTheme.primary.withOpacity(0.1))
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              inCart ? Icons.check_rounded : Icons.add_rounded,
                              size:  18,
                              color: product.isInStock
                                  ? (inCart ? Colors.white : AppTheme.primary)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}