// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = OrderService().fetchOrders();
  }

  void _reload() => setState(() {
        _future = OrderService().fetchOrders();
      });

  // ── Status helpers ────────────────────────────────────────
  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return const Color(0xFF1E88E5);
      case OrderStatus.shipped:   return const Color(0xFFF59E0B);
      case OrderStatus.delivered: return AppTheme.success;
      case OrderStatus.cancelled: return AppTheme.error;
      default:                    return AppTheme.textMuted;
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return Icons.check_circle_outline;
      case OrderStatus.shipped:   return Icons.local_shipping_outlined;
      case OrderStatus.delivered: return Icons.done_all_rounded;
      case OrderStatus.cancelled: return Icons.cancel_outlined;
      default:                    return Icons.hourglass_empty_rounded;
    }
  }

  String _statusLabel(OrderStatus s) => Helpers.capitalize(s.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon:     const Icon(Icons.refresh_rounded),
            tooltip:  'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future:  _future,
        builder: (_, snap) {
          // Loading
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          // Error
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text('Error: ${snap.error}',
                      style:
                          const TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final orders = snap.data ?? [];

          // Empty
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width:  110,
                    height: 110,
                    decoration: BoxDecoration(
                      color:  AppTheme.primary.withOpacity(0.08),
                      shape:  BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size:  52,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize:   20,
                      fontWeight: FontWeight.bold,
                      color:      AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your order history will appear here',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon:  const Icon(Icons.store_outlined, size: 18),
                    label: const Text('Start Shopping'),
                  ),
                ],
              ),
            );
          }

          // Orders list
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppTheme.primary,
            child: ListView.separated(
              padding:          const EdgeInsets.all(16),
              itemCount:        orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o     = orders[i];
                final color = _statusColor(o.status);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child:   Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──────────────────────────
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${o.id.substring(0, 8).toUpperCase()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:   15,
                                    color:      AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  Helpers.formatDate(o.createdAt),
                                  style: const TextStyle(
                                    color:   AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            // Status chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color:        color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: color.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_statusIcon(o.status),
                                      size: 13, color: color),
                                  const SizedBox(width: 5),
                                  Text(
                                    _statusLabel(o.status),
                                    style: TextStyle(
                                      color:      color,
                                      fontSize:   12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ── Items count + address ────────────
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined,
                                size: 15, color: AppTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '${o.items.length} item'
                              '${o.items.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                color:   AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        if (o.deliveryAddress.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 15, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  o.deliveryAddress,
                                  style: const TextStyle(
                                    color:   AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                  maxLines:  1,
                                  overflow:  TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),

                        // ── Total ────────────────────────────
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Total',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color:      AppTheme.textDark,
                              ),
                            ),
                            Text(
                              Helpers.formatPrice(o.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   16,
                                color:      AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}