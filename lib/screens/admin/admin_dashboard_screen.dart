// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'add_edit_product_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onNavigateToInventory;
  final VoidCallback onNavigateToOrders;

  const AdminDashboardScreen({
    super.key,
    required this.onNavigateToInventory,
    required this.onNavigateToOrders,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminSvc = AdminService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _future = _adminSvc.fetchDashboardStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Stats',
            onPressed: _loadStats,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
                  const SizedBox(height: 12),
                  Text('Failed to load stats: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loadStats, child: const Text('Retry')),
                ],
              ),
            );
          }

          final stats = snapshot.data ?? {};
          final totalProducts = stats['totalProducts'] ?? 0;
          final lowStockCount = stats['lowStockCount'] ?? 0;
          final totalOrders   = stats['totalOrders'] ?? 0;
          final pendingOrders = stats['pendingOrders'] ?? 0;
          final revenue       = (stats['revenue'] as num?)?.toDouble() ?? 0.0;

          return RefreshIndicator(
            onRefresh: () async => _loadStats(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Welcome Banner ───────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grocery Store Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Manage inventory, grocery items & orders',
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Metrics Grid ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Items',
                        value: '$totalProducts',
                        subtitle: 'In Grocery Catalog',
                        icon: Icons.inventory_2,
                        color: AppTheme.primary,
                        onTap: widget.onNavigateToInventory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Low Stock',
                        value: '$lowStockCount',
                        subtitle: '≤ 5 items left',
                        icon: Icons.warning_amber_rounded,
                        color: lowStockCount > 0 ? AppTheme.error : Colors.grey,
                        onTap: widget.onNavigateToInventory,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Pending Orders',
                        value: '$pendingOrders',
                        subtitle: 'Needs confirmation',
                        icon: Icons.access_time_filled,
                        color: pendingOrders > 0 ? const Color(0xFFF59E0B) : Colors.green,
                        onTap: widget.onNavigateToOrders,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Revenue',
                        value: '${AppText.currencySymbol} ${revenue.toStringAsFixed(0)}',
                        subtitle: '$totalOrders orders placed',
                        icon: Icons.payments,
                        color: const Color(0xFF1E88E5),
                        onTap: widget.onNavigateToOrders,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Quick Actions ────────────────────────────
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
                const SizedBox(height: 12),

                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.primaryLight,
                    child: Icon(Icons.add_shopping_cart, color: Colors.white),
                  ),
                  title: const Text('Add New Grocery Item', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Add items, set price, units and upload photos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final res = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
                    );
                    if (res == true) _loadStats();
                  },
                ),
                const SizedBox(height: 10),

                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E88E5),
                    child: Icon(Icons.list_alt, color: Colors.white),
                  ),
                  title: const Text('Manage Grocery Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Edit prices, adjust stocks, or delete items'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: widget.onNavigateToInventory,
                ),
                const SizedBox(height: 10),

                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF59E0B),
                    child: Icon(Icons.local_shipping, color: Colors.white),
                  ),
                  title: const Text('Customer Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Review customer orders and update shipping status'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: widget.onNavigateToOrders,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

