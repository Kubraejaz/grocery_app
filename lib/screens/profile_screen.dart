// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:grocery_app/utils/helpers.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'wishlist_screen.dart';
import 'addresses_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('My Profile')),
      body: ListView(
        children: [
          // ── Profile header card ───────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin:  Alignment.topLeft,
                end:    Alignment.bottomRight,
                colors: [AppTheme.primaryDark, AppTheme.primary],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:      AppTheme.primary.withOpacity(0.3),
                  blurRadius: 14,
                  offset:     const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width:  70,
                  height: 70,
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    shape:  BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      auth.userName.isNotEmpty
                          ? auth.userName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize:   30,
                        fontWeight: FontWeight.bold,
                        color:      AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Name + email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.userName,
                        style: const TextStyle(
                          color:      Colors.white,
                          fontSize:   18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        auth.userEmail,
                        style: const TextStyle(
                          color:   Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color:        Colors.white24,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Premium Member',
                          style: TextStyle(
                            color:   Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── My Account ────────────────────────────────
          _SectionLabel(label: 'My Account'),

          _MenuTile(
            icon:    Icons.receipt_long_outlined,
            label:   'My Orders',
            subtitle: 'Track and manage your orders',
            onTap:   () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
          _MenuTile(
            icon:     Icons.location_on_outlined,
            label:    'Saved Addresses',
            subtitle: 'Manage delivery addresses',
            onTap:    () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressesScreen()),
            ),
          ),
          _MenuTile(
            icon:     Icons.favorite_outline,
            label:    'Wishlist',
            subtitle: 'Products you saved for later',
            onTap:    () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            ),
          ),
          _MenuTile(
            icon:     Icons.local_offer_outlined,
            label:    'Coupons & Offers',
            subtitle: 'View available discounts',
            onTap:    () => Helpers.showSnack(context, 'Coming soon!'),
          ),

          _SectionLabel(label: 'Settings & Support'),

          _MenuTile(
            icon:     Icons.notifications_outlined,
            label:    'Notifications',
            subtitle: 'Manage your alerts',
            onTap:    () => Helpers.showSnack(context, 'Notifications settings coming soon'),
          ),
          _MenuTile(
            icon:     Icons.help_outline,
            label:    'Help & Support',
            subtitle: 'FAQs and contact us',
            onTap:    () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Help & Support'),
                content: const Text('For help, contact support@groceryapp.example'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            ),
          ),
          _MenuTile(
            icon:     Icons.privacy_tip_outlined,
            label:    'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap:    () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Privacy Policy'),
                content: const SingleChildScrollView(
                  child: Text('Privacy policy content goes here.'),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                ],
              ),
            ),
          ),
          _MenuTile(
            icon:     Icons.info_outline,
            label:    'About App',
            subtitle: 'Version 1.0.0',
            onTap:    () => showAboutDialog(
              context:            context,
              applicationName:    'Grocery App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2025 Grocery App',
            ),
          ),

          _SectionLabel(label: 'Account'),

          _MenuTile(
            icon:        Icons.logout_rounded,
            label:       'Logout',
            subtitle:    'Sign out of your account',
            iconColor:   AppTheme.error,
            labelColor:  AppTheme.error,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title:   const Text('Logout'),
                  content: const Text(
                      'Are you sure you want to sign out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: AppTheme.error),
                      ),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
        child:   Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize:      11,
            fontWeight:    FontWeight.w700,
            color:         AppTheme.textMuted,
            letterSpacing: 0.9,
          ),
        ),
      );
}

class _MenuTile extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final String     subtitle;
  final VoidCallback onTap;
  final Color?     iconColor;
  final Color?     labelColor;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child:  ListTile(
          leading: Container(
            width:  42,
            height: 42,
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppTheme.primary,
              size:  20,
            ),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color:      labelColor ?? AppTheme.textDark,
              fontSize:   14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color:    AppTheme.textMuted,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size:  14,
            color: AppTheme.textLight,
          ),
          onTap:           onTap,
          contentPadding:  const EdgeInsets.symmetric(
              horizontal: 16, vertical: 4),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      );
}