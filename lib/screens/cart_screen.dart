// lib/screens/cart_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('My Cart  (${cart.distinctCount} items)'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title:   const Text('Clear Cart'),
                    content: const Text(
                        'Remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(color: AppTheme.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (ok == true) cart.clear();
              },
              icon:  const Icon(Icons.delete_sweep_outlined,
                  color: Colors.white70, size: 18),
              label: const Text(
                'Clear',
                style: TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                // ── Items list ──────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding:    const EdgeInsets.all(16),
                    itemCount:  cart.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final item = cart.items[i];
                      return Dismissible(
                        key:       Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment:    Alignment.centerRight,
                          padding:      const EdgeInsets.only(right: 20),
                          decoration:   BoxDecoration(
                            color:        AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: AppTheme.error),
                        ),
                        confirmDismiss: (_) async => true,
                        onDismissed: (_) {
                          cart.remove(item.id);
                          Helpers.showSnack(
                              context, '${item.product.name} removed');
                        },
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
                                    imageUrl: item.product.imageUrl,
                                    width:    72,
                                    height:   72,
                                    fit:      BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width:  72,
                                      height: 72,
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
                                        item.product.name,
                                        maxLines:  2,
                                        overflow:  TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize:   14,
                                          color:      AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${Helpers.formatPrice(item.product.salePrice)} / ${item.product.unit}',
                                        style: const TextStyle(
                                          color:   AppTheme.primary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          // Qty controls
                                          _QtyBtn(
                                            icon:  Icons.remove_rounded,
                                            color: AppTheme.error,
                                            onTap: () => cart.updateQty(
                                              item.id,
                                              item.quantity - 1,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets
                                                .symmetric(horizontal: 12),
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 14,
                                                vertical:   4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primary
                                                  .withOpacity(0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:   15,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                          ),
                                          _QtyBtn(
                                            icon:  Icons.add_rounded,
                                            color: AppTheme.primary,
                                            onTap: () => cart.updateQty(
                                              item.id,
                                              item.quantity + 1,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            Helpers.formatPrice(
                                                item.subtotal),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize:   14,
                                              color:      AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // ── Order summary footer ────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset:     const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        _SummaryRow(
                          label: 'Subtotal (${cart.distinctCount} items)',
                          value: Helpers.formatPrice(cart.totalAmount),
                        ),
                        const SizedBox(height: 6),
                        const _SummaryRow(
                          label:      'Delivery Fee',
                          value:      'Free',
                          valueColor: AppTheme.success,
                        ),
                        const SizedBox(height: 6),
                        const _SummaryRow(
                          label: 'Discount',
                          value: '₨ 0.00',
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   16,
                                color:      AppTheme.textDark,
                              ),
                            ),
                            Text(
                              Helpers.formatPrice(cart.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   20,
                                color:      AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CheckoutScreen(),
                            ),
                          ),
                          icon:  const Icon(Icons.arrow_forward_rounded,
                              size: 18),
                          label: const Text('Proceed to Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  120,
              height: 120,
              decoration: BoxDecoration(
                color:        AppTheme.primary.withOpacity(0.08),
                shape:        BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size:  56,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize:   20,
                fontWeight: FontWeight.bold,
                color:      AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add items from the home screen to get started',
              textAlign: TextAlign.center,
              style:     TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon:       const Icon(Icons.store_outlined, size: 18),
              label:      const Text('Browse Products'),
            ),
          ],
        ),
      );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;

  const _QtyBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width:  30,
          height: 30,
          decoration: BoxDecoration(
            color:        color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 14)),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize:   14,
                color: valueColor ?? AppTheme.textDark,
              )),
        ],
      );
}