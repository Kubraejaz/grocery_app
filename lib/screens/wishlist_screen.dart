// lib/screens/wishlist_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WishlistProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();
    final cart     = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Wishlist  (${wishlist.count})'),
        actions: [
          if (wishlist.items.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title:   const Text('Clear Wishlist'),
                    content: const Text(
                        'Remove all items from your wishlist?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear',
                            style: TextStyle(color: AppTheme.error)),
                      ),
                    ],
                  ),
                );
                if (ok == true) wishlist.clear();
              },
              icon:  const Icon(Icons.delete_sweep_outlined,
                  color: Colors.white70, size: 18),
              label: const Text('Clear',
                  style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),

      body: wishlist.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : wishlist.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width:  110,
                        height: 110,
                        decoration: BoxDecoration(
                          color:  Colors.red.withOpacity(0.08),
                          shape:  BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border_rounded,
                            size: 52, color: Colors.red),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Your wishlist is empty',
                        style: TextStyle(
                          fontSize:   20,
                          fontWeight: FontWeight.bold,
                          color:      AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the ♥ on any product to save it here',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon:  const Icon(Icons.store_outlined, size: 18),
                        label: const Text('Browse Products'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding:          const EdgeInsets.all(16),
                  itemCount:        wishlist.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final item    = wishlist.items[i];
                    final product = item.product;
                    final inCart  = cart.isInCart(product.id);

                    return Dismissible(
                      key:       Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment:    Alignment.centerRight,
                        padding:      const EdgeInsets.only(right: 20),
                        decoration:   BoxDecoration(
                          color:        Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.red),
                      ),
                      onDismissed: (_) {
                        wishlist.remove(product.id);
                        Helpers.showSnack(context,
                            '${product.name} removed from wishlist');
                      },
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child:  Padding(
                            padding: const EdgeInsets.all(12),
                            child:   Row(
                              children: [
                                // Product image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    width:    80,
                                    height:   80,
                                    fit:      BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width:  80,
                                      height: 80,
                                      color:  Colors.grey.shade100,
                                      child:  const Icon(Icons.image,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize:   14,
                                          color:      AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            Helpers.formatPrice(
                                                product.salePrice),
                                            style: const TextStyle(
                                              color:      AppTheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize:   14,
                                            ),
                                          ),
                                          if (product.isOnSale) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              Helpers.formatPrice(
                                                  product.price),
                                              style: const TextStyle(
                                                fontSize:   12,
                                                color: AppTheme.textLight,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Stock status
                                      Text(
                                        product.isInStock
                                            ? '${product.stock} in stock'
                                            : 'Out of stock',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:    product.isInStock
                                              ? AppTheme.success
                                              : AppTheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Action buttons column
                                Column(
                                  children: [
                                    // Remove from wishlist
                                    GestureDetector(
                                      onTap: () {
                                        wishlist.remove(product.id);
                                        Helpers.showSnack(context,
                                            'Removed from wishlist');
                                      },
                                      child: Container(
                                        width:  34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color:        Colors.red.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          size:  18,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Add to cart
                                    GestureDetector(
                                      onTap: product.isInStock
                                          ? () async {
                                              await cart.add(product.id);
                                              if (!context.mounted) return;
                                              Helpers.showSnack(
                                                context,
                                                inCart
                                                    ? 'Already in cart!'
                                                    : '${product.name} added to cart!',
                                              );
                                            }
                                          : null,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 200),
                                        width:  34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: product.isInStock
                                              ? (inCart
                                                  ? AppTheme.primary
                                                  : AppTheme.primary
                                                      .withOpacity(0.1))
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          inCart
                                              ? Icons.shopping_cart_rounded
                                              : Icons.add_shopping_cart_outlined,
                                          size:  18,
                                          color: product.isInStock
                                              ? (inCart
                                                  ? Colors.white
                                                  : AppTheme.primary)
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
                      ),
                    );
                  },
                ),
    );
  }
}