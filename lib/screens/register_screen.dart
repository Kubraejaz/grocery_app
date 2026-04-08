// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool  _obscurePass    = true;
  bool  _obscureConfirm = true;

  // Real-time field error states
  String? _nameError;
  String? _emailError;
  String? _passError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Clear previous server errors
    setState(() {
      _nameError    = null;
      _emailError   = null;
      _passError    = null;
      _confirmError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final auth   = context.read<AuthProvider>();
    final result = await auth.signUp(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result == 'success') {
      await context.read<ProductProvider>().init();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else if (result == 'confirm') {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_unread_outlined,
                    color: AppTheme.primary, size: 38),
              ),
              const SizedBox(height: 16),
              const Text('Check Your Email',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark)),
              const SizedBox(height: 10),
              Text(
                'We sent a confirmation link to:\n'
                '${_emailCtrl.text.trim()}\n\n'
                'Click the link to activate your account, then login.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textMuted, height: 1.5),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      // Map server error to the correct field
      final err = auth.error ?? '';
      if (err.toLowerCase().contains('already registered') ||
          err.toLowerCase().contains('already been registered') ||
          err.toLowerCase().contains('duplicate') ||
          err.toLowerCase().contains('email')) {
        setState(() => _emailError =
            'This email is already registered. Please login instead.');
      } else if (err.toLowerCase().contains('password')) {
        setState(() => _passError = err);
      } else {
        Helpers.showSnack(context,
            err.isNotEmpty ? err : 'Registration failed. Please try again.',
            error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        title: const Text('Create Account',
            style: TextStyle(color: AppTheme.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryLight]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_add_outlined,
                      color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Join Grocery App',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text('Fresh groceries delivered to you',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Form(
              key: _formKey,
              child: Column(
                children: [

                  // ── Full Name ───────────────────────────
                  TextFormField(
                    controller:         _nameCtrl,
                    keyboardType:       TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) =>
                        setState(() => _nameError = null),
                    decoration: InputDecoration(
                      labelText:  'Full Name',
                      hintText:   'e.g. Ali Hassan',
                      prefixIcon: const Icon(Icons.person_outline),
                      errorText:  _nameError,
                    ),
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 16),

                  // ── Email ───────────────────────────────
                  TextFormField(
                    controller:   _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    onChanged:    (_) =>
                        setState(() => _emailError = null),
                    decoration: InputDecoration(
                      labelText:  'Email Address',
                      hintText:   'you@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      errorText:  _emailError,
                      // Show red border if server returned email error
                      focusedBorder: _emailError != null
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: AppTheme.error, width: 2),
                            )
                          : null,
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),

                  // ── Password ────────────────────────────
                  TextFormField(
                    controller:  _passCtrl,
                    obscureText: _obscurePass,
                    onChanged:   (_) {
                      setState(() => _passError = null);
                      // Re-validate confirm when password changes
                      if (_confirmCtrl.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },
                    decoration: InputDecoration(
                      labelText:  'Password',
                      hintText:   'Min. 6 chars, include a letter & number',
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText:  _passError,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm Password ────────────────────
                  TextFormField(
                    controller:  _confirmCtrl,
                    obscureText: _obscureConfirm,
                    onChanged:   (_) =>
                        setState(() => _confirmError = null),
                    decoration: InputDecoration(
                      labelText:  'Confirm Password',
                      hintText:   'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      errorText:  _confirmError,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) =>
                        Validators.confirmPassword(v, _passCtrl.text),
                  ),
                  const SizedBox(height: 8),

                  // Password hint
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '• At least 6 characters\n'
                      '• Must include a letter and a number',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Register button
                  ElevatedButton(
                    onPressed: auth.loading ? null : _register,
                    child: auth.loading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?  ',
                          style: TextStyle(color: AppTheme.textMuted)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Login',
                            style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}