// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:     SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: _RootGestureGuard(
        child: MaterialApp(
          title: 'Grocery App',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class _RootGestureGuard extends StatefulWidget {
  final Widget child;
  const _RootGestureGuard({required this.child});

  @override
  State<_RootGestureGuard> createState() => _RootGestureGuardState();
}

class _RootGestureGuardState extends State<_RootGestureGuard> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Defer interactions until first frame is rendered to avoid
    // hit-testing RenderBoxes that haven't been laid out yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_ready,
      child: widget.child,
    );
  }
}