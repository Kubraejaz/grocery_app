// lib/screens/splash_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/grocery_logo.dart';
import 'admin/admin_main_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';

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

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve:  const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve:  const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!onboardingCompleted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.loggedIn) {
      await auth.loadProfile();
      if (!mounted) return;
      await context.read<ProductProvider>().init();
      if (!mounted) return;

      if (auth.isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
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
      backgroundColor: const Color(0xFFFBFDFB),
      body: Stack(
        children: [
          // ── Top Decorative Organic Green Wave ─────────────────
          Positioned(
            top: -50,
            left: -40,
            right: -40,
            child: Container(
              height: 220,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFC8E6C9),
                    Color(0xFFE8F5E9),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(320, 140),
                ),
              ),
            ),
          ),

          // ── Floating Leaves Accents ───────────────────────────
          Positioned(
            top: 60,
            right: 28,
            child: Transform.rotate(
              angle: 0.4,
              child: const Icon(Icons.eco_rounded, color: Color(0xFF81C784), size: 30),
            ),
          ),
          Positioned(
            top: 130,
            left: 20,
            child: Transform.rotate(
              angle: -0.6,
              child: const Icon(Icons.eco_rounded, color: Color(0xFFA5D6A7), size: 24),
            ),
          ),

          // ── Center Content ────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),

                // ── Animated 3D Grocery Cart Logo ─────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: const GroceryCartLogo(size: 130),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Branding Title ────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const GroceryBrandTitle(fontSize: 38),
                ),
                const SizedBox(height: 12),

                // ── Subtitle ──────────────────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: const Column(
                    children: [
                      Text(
                        'Fresh Groceries',
                        style: TextStyle(
                          color: Color(0xFF455A64),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Delivered to Your Door',
                        style: TextStyle(
                          color: Color(0xFF78909C),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Fresh Produce Basket Image ────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=700&auto=format&fit=crop&q=80',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 180,
                        color: const Color(0xFFE8F5E9),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF4CAF50),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 180,
                        color: const Color(0xFFE8F5E9),
                        child: const Icon(Icons.shopping_basket,
                            size: 64, color: Color(0xFF4CAF50)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── 3 Dots Carousel Indicator ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC8E6C9),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 22,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC8E6C9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
