// lib/screens/admin/admin_main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/helpers.dart';
import '../login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final List<Widget> screens = [
      AdminDashboardScreen(
        onNavigateToInventory: () => setState(() => _selectedIndex = 1),
        onNavigateToOrders: () => setState(() => _selectedIndex = 2),
      ),
      const AdminProductsScreen(),
      const AdminOrdersScreen(),
      _AdminSettingsTab(auth: auth),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _AdminSettingsTab extends StatefulWidget {
  final AuthProvider auth;
  const _AdminSettingsTab({required this.auth});

  @override
  State<_AdminSettingsTab> createState() => _AdminSettingsTabState();
}

class _AdminSettingsTabState extends State<_AdminSettingsTab> {
  String _storeName = 'Fresh Grocery Mart';
  String _currency = 'PKR (₨)';
  String _deliveryFee = 'Free above ₨ 500 (₨ 50 standard)';
  String _operatingHours = '08:00 AM - 11:00 PM';
  bool _autoConfirmOrders = true;
  bool _lowStockAlerts = true;
  bool _soundAlerts = true;
  bool _hideOutOfStock = false;
  int _lowStockThreshold = 5;

  void _editSettingDialog(String title, String currentVal, Function(String) onSave) {
    final ctrl = TextEditingController(text: currentVal);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $title', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onSave(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = widget.auth;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Store & Admin Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ── 1. Admin Profile Card ───────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 36),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              auth.userName.isNotEmpty ? auth.userName : 'Store Administrator',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        auth.userEmail,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF69F0AE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Active Session • Role ID 1',
                            style: TextStyle(color: Color(0xFFE8F5E9), fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 2. Store Configuration ──────────────────────────
          _buildSectionHeader('Store & Business Profile'),
          _buildSettingsCard([
            _buildActionTile(
              icon: Icons.storefront_rounded,
              title: 'Store Name',
              subtitle: _storeName,
              onTap: () => _editSettingDialog('Store Name', _storeName, (v) => setState(() => _storeName = v)),
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.monetization_on_outlined,
              title: 'Store Currency',
              subtitle: _currency,
              onTap: () => _editSettingDialog('Store Currency', _currency, (v) => setState(() => _currency = v)),
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.access_time_rounded,
              title: 'Business Hours',
              subtitle: _operatingHours,
              onTap: () => _editSettingDialog('Operating Hours', _operatingHours, (v) => setState(() => _operatingHours = v)),
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.local_shipping_outlined,
              title: 'Delivery Rules',
              subtitle: _deliveryFee,
              onTap: () => _editSettingDialog('Delivery Rules', _deliveryFee, (v) => setState(() => _deliveryFee = v)),
            ),
          ]),
          const SizedBox(height: 18),

          // ── 3. Orders & Automation ──────────────────────────
          _buildSectionHeader('Orders & Inventory Automation'),
          _buildSettingsCard([
            _buildSwitchTile(
              icon: Icons.bolt_rounded,
              title: 'Auto-Confirm Orders',
              subtitle: 'Automatically accept incoming customer orders',
              value: _autoConfirmOrders,
              onChanged: (v) => setState(() => _autoConfirmOrders = v),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Low Stock Alerts',
              subtitle: 'Trigger warning when items drop ≤ $_lowStockThreshold units',
              value: _lowStockAlerts,
              onChanged: (v) => setState(() => _lowStockAlerts = v),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.volume_up_outlined,
              title: 'Order Sound Chime',
              subtitle: 'Play sound notification on new order placement',
              value: _soundAlerts,
              onChanged: (v) => setState(() => _soundAlerts = v),
            ),
            const Divider(height: 1),
            _buildSwitchTile(
              icon: Icons.visibility_off_outlined,
              title: 'Hide Out of Stock',
              subtitle: 'Hide zero-stock grocery items from storefront',
              value: _hideOutOfStock,
              onChanged: (v) => setState(() => _hideOutOfStock = v),
            ),
          ]),
          const SizedBox(height: 18),

          // ── 4. Cloud Database & System ──────────────────────
          _buildSectionHeader('Cloud Database & Cache'),
          _buildSettingsCard([
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF2E7D32), size: 22),
              ),
              title: const Text('Supabase Cloud Database', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: const Text('PostgreSQL Cluster • Connected', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              trailing: TextButton(
                onPressed: () async {
                  await context.read<ProductProvider>().init();
                  if (!context.mounted) return;
                  Helpers.showSnack(context, 'Cloud database synchronized!');
                },
                child: const Text('Sync Now'),
              ),
            ),
            const Divider(height: 1),
            _buildActionTile(
              icon: Icons.cleaning_services_rounded,
              title: 'Clear Local Store Cache',
              subtitle: 'Refresh images, categories & catalog cache',
              onTap: () {
                Helpers.showSnack(context, 'Local cache refreshed successfully!');
              },
            ),
          ]),
          const SizedBox(height: 18),

          // ── 5. App & Role Information ───────────────────────
          _buildSectionHeader('System & App Architecture'),
          _buildSettingsCard([
            _buildInfoTile('App Version', '2.4.0 (Build 108)'),
            const Divider(height: 1),
            _buildInfoTile('Architecture', 'Segregated Admin (1) & Customer (2)'),
            const Divider(height: 1),
            _buildInfoTile('Security Policy', 'Row Level Security Configured'),
          ]),
          const SizedBox(height: 22),

          // ── 6. Sign Out Button ──────────────────────────────
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 1,
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
              ),
              title: const Text(
                'Sign Out from Admin Panel',
                style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: const Text('Securely end current administrator session'),
              onTap: () => _confirmSignOut(context, auth),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      value: value,
      activeColor: const Color(0xFF2E7D32),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to end your administrator session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
