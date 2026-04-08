// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';
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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth    = context.read<AuthProvider>();
    final success = await auth.signIn(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      // Load products then navigate to Home
      await context.read<ProductProvider>().init();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Show the specific error from auth provider
      if (auth.needsConfirmation) {
        // Show a special dialog for unconfirmed email
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width:  64,
                  height: 64,
                  decoration: BoxDecoration(
                    color:  AppTheme.warning.withOpacity(0.1),
                    shape:  BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppTheme.warning,
                    size:  34,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Email Not Confirmed',
                  style: TextStyle(
                    fontSize:   18,
                    fontWeight: FontWeight.bold,
                    color:      AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please check your inbox and click the '
                  'confirmation link we sent you, then try logging in again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:  AppTheme.textMuted,
                    height: 1.5,
                  ),
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
        Helpers.showSnack(
          context,
          auth.error ?? 'Login failed. Please try again.',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Green header banner ───────────────────────
            Container(
              width:  double.infinity,
              height: size.height * 0.30,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:    Alignment.bottomRight,
                  colors: [AppTheme.primaryDark, AppTheme.primary],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft:  Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width:  80,
                    height: 80,
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.shopping_basket_rounded,
                      size:  44,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Grocery App',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ── Form ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize:   26,
                      fontWeight: FontWeight.bold,
                      color:      AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to continue shopping',
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 28),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller:   _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration:   const InputDecoration(
                            labelText:  'Email Address',
                            hintText:   'you@example.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Please enter your email';
                            if (!RegExp(r'^[\w-.]+@[\w-]+\.\w+$')
                                .hasMatch(v.trim()))
                              return 'Enter a valid email address';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller:  _passCtrl,
                          obscureText: _obscure,
                          decoration:  InputDecoration(
                            labelText:  'Password',
                            hintText:   'Min. 6 characters',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return 'Please enter your password';
                            if (v.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Login button
                        ElevatedButton(
                          onPressed: auth.loading ? null : _login,
                          child: auth.loading
                              ? const SizedBox(
                                  height: 22,
                                  width:  22,
                                  child:  CircularProgressIndicator(
                                    color:       Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 20),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?  ",
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color:      AppTheme.primary,
                                  fontWeight: FontWeight.w700,
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
          ],
        ),
      ),
    );
  }
}