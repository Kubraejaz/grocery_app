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
  OrderStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _future = OrderService().fetchOrders();
  }

  void _reload() => setState(() {
        _future = OrderService().fetchOrders();
      });

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:
        return const Color(0xFF1E88E5);
      case OrderStatus.shipped:
        return const Color(0xFFF59E0B);
      case OrderStatus.delivered:
        return AppTheme.success;
      case OrderStatus.cancelled:
        return AppTheme.error;
      default:
        return const Color(0xFF8E24AA);
    }
  }

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.shipped:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.done_all_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _statusLabel(OrderStatus s) => Helpers.capitalize(s.name);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Grocery Orders'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status Filter Chips ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pending', OrderStatus.pending),
                  const SizedBox(width: 8),
                  _buildFilterChip('Confirmed', OrderStatus.confirmed),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delivered', OrderStatus.delivered),
                ],
              ),
            ),
          ),

          // ── Orders List ─────────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 56, color: AppTheme.error),
                        const SizedBox(height: 12),
                        const Text('Unable to load orders',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('${snap.error}',
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                var orders = snap.data ?? [];
                if (_filterStatus != null) {
                  orders = orders.where((o) => o.status == _filterStatus).toList();
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No orders found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Your orders will appear here once you checkout.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.store_outlined, size: 18),
                            label: const Text('Browse Groceries'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  color: AppTheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final o = orders[i];
                      final color = _statusColor(o.status);

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 1.5,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _statusIcon(o.status),
                                color: color,
                                size: 22,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order #${o.id.substring(0, 8).toUpperCase()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.textDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: color.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    _statusLabel(o.status),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    Helpers.formatDate(o.createdAt),
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    Helpers.formatPrice(o.totalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            children: [
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // Delivery Address
                                    if (o.deliveryAddress.isNotEmpty) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 16,
                                              color: AppTheme.primary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              o.deliveryAddress,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF4B5563),
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],

                                    // Ordered Items Header
                                    Text(
                                      'Order Items (${o.items.length}):',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Items List
                                    ...o.items.map((it) {
                                      final pName = (it['products'] as Map?)?['name'] as String? ?? 'Grocery item';
                                      final qty = it['quantity'] ?? 1;
                                      final price = (it['unit_price'] as num?)?.toDouble() ?? 0.0;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle,
                                                size: 6,
                                                color: AppTheme.primary),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '$pName x$qty',
                                                style: const TextStyle(
                                                    fontSize: 12),
                                              ),
                                            ),
                                            Text(
                                              Helpers.formatPrice(qty * price),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                                color: AppTheme.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),

                                    const SizedBox(height: 10),
                                    const Divider(height: 1),
                                    const SizedBox(height: 10),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total Amount Paid:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          Helpers.formatPrice(o.totalAmount),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.primary,
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
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status) {
    final selected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
