// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
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

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth   = context.read<AuthProvider>();
    final result = await auth.signUp(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result == 'success') {
      // Email confirmation is OFF → user is fully logged in → go to Home
      await context.read<ProductProvider>().init();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );

    } else if (result == 'confirm') {
      // Email confirmation is ON → show dialog, then go to Login
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
                width:  72,
                height: 72,
                decoration: BoxDecoration(
                  color:  AppTheme.primary.withOpacity(0.1),
                  shape:  BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppTheme.primary,
                  size:  38,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize:   20,
                  fontWeight: FontWeight.bold,
                  color:      AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a confirmation link to:\n${_emailCtrl.text.trim()}\n\n'
                'Please click the link in the email to activate your account, '
                'then come back and login.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color:  AppTheme.textMuted,
                  height: 1.5,
                ),
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

      // After dialog closes → go to Login screen
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );

    } else {
      // Error → show snack with error message
      Helpers.showSnack(
        context,
        auth.error ?? 'Registration failed. Please try again.',
        error: true,
      );
    }
  }

  Widget _buildField({
    required TextEditingController    controller,
    required String                   label,
    required String                   hint,
    required IconData                 icon,
    bool                              obscure       = false,
    VoidCallback?                     toggleObscure,
    TextInputType                     keyboardType  = TextInputType.text,
    String? Function(String?)?        validator,
  }) {
    return TextFormField(
      controller:         controller,
      obscureText:        obscure,
      keyboardType:       keyboardType,
      textCapitalization: keyboardType == TextInputType.name
          ? TextCapitalization.words
          : TextCapitalization.none,
      decoration: InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: Icon(icon),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: toggleObscure,
              )
            : null,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.textDark,
        elevation:       0,
        title: const Text(
          'Create Account',
          style: TextStyle(color: AppTheme.textDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header banner ─────────────────────────────
            Container(
              padding:    const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryLight],
                ),
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
                      Text(
                        'Join Grocery App',
                        style: TextStyle(
                          color:      Colors.white,
                          fontSize:   18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fresh groceries delivered to you',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
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
                  // Full Name
                  _buildField(
                    controller:   _nameCtrl,
                    label:        'Full Name',
                    hint:         'Ali Hassan',
                    icon:         Icons.person_outline,
                    keyboardType: TextInputType.name,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your full name'
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildField(
                    controller:   _emailCtrl,
                    label:        'Email Address',
                    hint:         'you@example.com',
                    icon:         Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
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
                  _buildField(
                    controller:    _passCtrl,
                    label:         'Password',
                    hint:          'Min. 6 characters',
                    icon:          Icons.lock_outline,
                    obscure:       _obscurePass,
                    toggleObscure: () =>
                        setState(() => _obscurePass = !_obscurePass),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Please enter a password';
                      if (v.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  _buildField(
                    controller:    _confirmCtrl,
                    label:         'Confirm Password',
                    hint:          'Re-enter password',
                    icon:          Icons.lock_outline,
                    obscure:       _obscureConfirm,
                    toggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) => v != _passCtrl.text
                        ? 'Passwords do not match'
                        : null,
                  ),
                  const SizedBox(height: 28),

                  // Register button
                  ElevatedButton(
                    onPressed: auth.loading ? null : _register,
                    child: auth.loading
                        ? const SizedBox(
                            height: 22,
                            width:  22,
                            child:  CircularProgressIndicator(
                              color:       Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 20),

                  // Back to login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?  ',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color:      AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
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
      ),
    );
  }
}