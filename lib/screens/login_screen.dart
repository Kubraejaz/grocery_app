// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:grocery_app/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
import '../widgets/grocery_logo.dart';
import 'admin/admin_main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool  _obscure   = true;

  // Field-level server error
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _emailError = null; _passError = null; });

    if (!_formKey.currentState!.validate()) return;

    final auth    = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
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
      if (auth.needsConfirmation) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_unread_outlined,
                      color: AppTheme.warning, size: 34),
                ),
                const SizedBox(height: 14),
                const Text('Email Not Confirmed',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark)),
                const SizedBox(height: 8),
                const Text(
                  'Please check your inbox and click the '
                  'confirmation link, then try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted, height: 1.5),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK, Got it'),
                ),
              ],
            ),
          ),
        );
      } else {
        final err = auth.error ?? '';
        if (err.toLowerCase().contains('invalid login credentials') ||
            err.toLowerCase().contains('invalid credentials')) {
          setState(() {
            _emailError = ' ';
            _passError  = 'Incorrect email or password. Please try again.';
          });
        } else if (err.toLowerCase().contains('email')) {
          setState(() => _emailError = err);
        } else if (err.toLowerCase().contains('password')) {
          setState(() => _passError = err);
        } else {
          Helpers.showSnack(context,
              err.isNotEmpty ? err : 'Login failed. Please try again.',
              error: true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Top Header with Green Wave, Badge & Brand ──
            ClipPath(
              clipper: _LoginHeaderClipper(),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2E7D32),
                      Color(0xFF388E3C),
                      Color(0xFF43A047),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative floating leaves
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Transform.rotate(
                        angle: -0.4,
                        child: Icon(Icons.eco,
                            size: 32,
                            color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    Positioned(
                      top: 55,
                      right: 25,
                      child: Transform.rotate(
                        angle: 0.6,
                        child: Icon(Icons.eco,
                            size: 40,
                            color: Colors.white.withOpacity(0.22)),
                      ),
                    ),
                    Positioned(
                      bottom: 70,
                      left: 45,
                      child: Transform.rotate(
                        angle: 0.2,
                        child: Icon(Icons.eco,
                            size: 26,
                            color: Colors.white.withOpacity(0.18)),
                      ),
                    ),

                    // Centered floating badge & Grocery App text
                    SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 8),
                            // White rounded card with 3D cart logo
                            const GroceryCartLogo(size: 80),
                            const SizedBox(height: 10),
                            const Text(
                              'Grocery App',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Main Content Form ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to continue shopping',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Email Field ───────────────────────
                        TextFormField(
                          controller:   _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) =>
                              setState(() => _emailError = null),
                          decoration: _inputDecoration(
                            hint: 'Email Address',
                            icon: Icons.mail_outline_rounded,
                            errorText: _emailError?.trim().isEmpty == true
                                ? null
                                : _emailError,
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        // ── Password Field ────────────────────
                        TextFormField(
                          controller:  _passCtrl,
                          obscureText: _obscure,
                          onChanged:   (_) =>
                              setState(() => _passError = null),
                          decoration: _inputDecoration(
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            errorText: _passError,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF9E9E9E),
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // ── Login Pill Button ─────────────────
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            onPressed: auth.loading ? null : _login,
                            child: auth.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // ── Don't have an account? Register ───
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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

            const SizedBox(height: 16),

            // ── Bottom Illustration (Grocery Paper Bag & Wave Hill) ──
            const _BottomGroceryIllustration(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? errorText,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF757575), size: 20),
      suffixIcon: suffix,
      errorText: errorText,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.8),
      ),
    );
  }
}

// ── Organic Wave Clipper for Login Header ──
class _LoginHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);

    final p1 = Offset(size.width * 0.28, size.height);
    final p2 = Offset(size.width * 0.58, size.height - 25);
    path.quadraticBezierTo(p1.dx, p1.dy, p2.dx, p2.dy);

    final p3 = Offset(size.width * 0.82, size.height - 46);
    final p4 = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(p3.dx, p3.dy, p4.dx, p4.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ── Bottom Grocery Bag Illustration with Fresh Produce & Hills ──
class _BottomGroceryIllustration extends StatelessWidget {
  const _BottomGroceryIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Background soft green rolling hill
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: _BottomHillClipper(),
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // Floating leaves on sides
          Positioned(
            bottom: 30,
            left: 20,
            child: Transform.rotate(
              angle: -0.3,
              child: const Icon(Icons.eco, color: Color(0xFF2E7D32), size: 30),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 25,
            child: Transform.rotate(
              angle: 0.4,
              child: const Icon(Icons.eco, color: Color(0xFF388E3C), size: 36),
            ),
          ),

          // Centered Grocery Bag
          Positioned(
            bottom: 8,
            child: Container(
              width: 140,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFD29860), // Kraft paper bag
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Fold line on paper bag
                  Positioned(
                    top: 14,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 1.5,
                      color: const Color(0xFFB57C42),
                    ),
                  ),
                  // Paper bag handle cutout
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 22),
                      width: 44,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB57C42),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  // Fresh Veggies poking out from top
                  Positioned(
                    top: -24,
                    left: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Fresh green lettuce / broccoli cluster
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43A047),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.grass_rounded,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 4),
                        // Red shiny tomato
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE53935),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.eco,
                                color: Colors.green, size: 10),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Golden Baguette / Bread loaf
                        Transform.rotate(
                          angle: 0.25,
                          child: Container(
                            width: 18,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD7A15C),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                  color: const Color(0xFFBF843B), width: 1),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Milk bottle
                        Container(
                          width: 16,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: const Color(0xFFBBDEFB), width: 1.5),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 12,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1976D2),
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(2)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _BottomHillClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width * 0.35, 0, size.width * 0.65, 20);
    path.quadraticBezierTo(size.width * 0.85, 35, size.width, 15);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
