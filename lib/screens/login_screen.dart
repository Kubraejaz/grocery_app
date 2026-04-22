// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:grocery_app/screens/main_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
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
        // Map server error to correct field
        final err = auth.error ?? '';
        if (err.toLowerCase().contains('invalid login credentials') ||
            err.toLowerCase().contains('invalid credentials')) {
          setState(() {
            _emailError = ' '; // space triggers red border without text
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
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────
            Container(
              width: double.infinity,
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
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.shopping_basket_rounded,
                        size: 44, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  const Text('Grocery App',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  const Text('Welcome Back!',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue shopping',
                      style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 28),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        // ── Email ───────────────────────────
                        TextFormField(
                          controller:   _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) =>
                              setState(() => _emailError = null),
                          decoration: InputDecoration(
                            labelText:  'Email Address',
                            hintText:   'you@example.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            errorText: _emailError?.trim().isEmpty == true
                                ? null
                                : _emailError,
                          ),
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),

                        // ── Password ────────────────────────
                        TextFormField(
                          controller:  _passCtrl,
                          obscureText: _obscure,
                          onChanged:   (_) =>
                              setState(() => _passError = null),
                          decoration: InputDecoration(
                            labelText:  'Password',
                            hintText:   'Your password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorText:  _passError,
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
                              return 'Password is required';
                            if (v.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        ElevatedButton(
                          onPressed: auth.loading ? null : _login,
                          child: auth.loading
                              ? const SizedBox(
                                  height: 22, width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2))
                              : const Text('Login'),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account?  ",
                                style: TextStyle(
                                    color: AppTheme.textMuted)),
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen()),
                              ),
                              child: const Text('Register',
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w700)),
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