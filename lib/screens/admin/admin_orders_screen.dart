// lib/screens/admin/admin_orders_screen.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _adminSvc = AdminService();
  OrderStatus? _selectedFilter;
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _future = _adminSvc.fetchAllOrders(statusFilter: _selectedFilter);
    });
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed: return const Color(0xFF1E88E5);
      case OrderStatus.shipped:   return const Color(0xFFF59E0B);
      case OrderStatus.delivered: return AppTheme.success;
      case OrderStatus.cancelled: return AppTheme.error;
      default:                    return Colors.grey.shade600;
    }
  }

  Future<void> _updateStatus(Order order, OrderStatus newStatus) async {
    try {
      await _adminSvc.updateOrderStatus(order.id, newStatus);
      if (!mounted) return;
      Helpers.showSnack(
        context,
        'Order #${order.id.substring(0, 8).toUpperCase()} updated to ${Helpers.capitalize(newStatus.name)}',
      );
      _loadOrders();
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnack(context, 'Failed to update order status: $e', error: true);
    }
  }

  void _showStatusDialog(Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Update Status (#${order.id.substring(0, 8).toUpperCase()})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...OrderStatus.values.map(
                (status) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(status).withOpacity(0.15),
                    child: Icon(
                      status == order.status
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _statusColor(status),
                    ),
                  ),
                  title: Text(Helpers.capitalize(status.name)),
                  selected: status == order.status,
                  onTap: () {
                    Navigator.pop(context);
                    if (status != order.status) {
                      _updateStatus(order, status);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Store Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Status Filter Chips ──────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Orders'),
                  selected: _selectedFilter == null,
                  onSelected: (_) {
                    setState(() => _selectedFilter = null);
                    _loadOrders();
                  },
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(Helpers.capitalize(s.name)),
                      selected: _selectedFilter == s,
                      onSelected: (_) {
                        setState(() => _selectedFilter = s);
                        _loadOrders();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Orders List ──────────────────────────────────
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                          const SizedBox(height: 12),
                          Text('Failed to load orders: ${snapshot.error}', textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _loadOrders, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  );
                }

                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No orders found matching filter.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final o = orders[index];
                    final color = _statusColor(o.status);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.12),
                          child: Icon(Icons.shopping_bag, color: color, size: 20),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${o.id.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                Helpers.capitalize(o.status.name),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${AppText.currencySymbol} ${o.totalAmount.toStringAsFixed(0)} • ${Helpers.formatDate(o.createdAt)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.textDark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        trailing: InkWell(
                          onTap: () => _showStatusDialog(o),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                          ),
                        ),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Delivery Information:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  o.deliveryAddress.isNotEmpty ? o.deliveryAddress : 'No address provided',
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Ordered Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 8),
                                ...o.items.map((item) {
                                  final name = (item['products'] as Map?)?['name'] as String? ?? 'Grocery item';
                                  final qty = item['quantity'] ?? 1;
                                  final unitPrice = item['unit_price'] ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('• $name x $qty', style: const TextStyle(fontSize: 13)),
                                        Text('${AppText.currencySymbol} ${(qty * unitPrice).toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

