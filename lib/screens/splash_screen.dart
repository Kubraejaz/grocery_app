// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<double>   _scaleAnim;
  late final Animation<double>   _slideAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve:  const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve:  const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve:  const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.loggedIn) {
      await context.read<ProductProvider>().init();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
            colors: [
              AppTheme.primaryDark,
              AppTheme.primary,
              AppTheme.primaryLight,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo icon ──────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width:  110,
                      height: 110,
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:      Colors.black.withOpacity(0.2),
                            blurRadius: 24,
                            offset:     const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shopping_basket_rounded,
                        size:  60,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── App name ───────────────────────────────
                Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: const Text(
                      'Grocery App',
                      style: TextStyle(
                        color:          Colors.white,
                        fontSize:       34,
                        fontWeight:     FontWeight.bold,
                        letterSpacing:  1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Tagline ────────────────────────────────
                Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: const Text(
                      'Fresh. Fast. Delivered.',
                      style: TextStyle(
                        color:       Colors.white70,
                        fontSize:    16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // ── Loader ─────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const SizedBox(
                    width:  28,
                    height: 28,
                    child:  CircularProgressIndicator(
                      color:       Colors.white60,
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}