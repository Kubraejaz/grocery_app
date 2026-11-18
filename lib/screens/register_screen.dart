// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/validators.dart';
import 'admin/admin_main_screen.dart';
import 'login_screen.dart';
import 'main_screen.dart';

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

  String? _nameError;
  String? _emailError;
  String? _passError;

  bool get _hasMinLength => _passCtrl.text.length >= 6;
  bool get _hasLetterAndNumber {
    final t = _passCtrl.text;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(t);
    final hasNumber = RegExp(r'[0-9]').hasMatch(t);
    return hasLetter && hasNumber;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _nameError  = null;
      _emailError = null;
      _passError  = null;
    });

    if (!_formKey.currentState!.validate()) return;

    final auth   = context.read<AuthProvider>();
    final result = await auth.signUp(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      _nameCtrl.text.trim(),
      userType: UserTypes.user,
    );

    if (!mounted) return;

    if (result == 'success') {
      await context.read<ProductProvider>().init();
      if (!mounted) return;
      if (auth.isAdmin) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          (_) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (_) => false,
        );
      }
    } else if (result == 'confirm') {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
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
                style: const TextStyle(color: AppTheme.textMuted, height: 1.5),
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
      final err = auth.error ?? '';
      final isAlreadyRegistered = err.toLowerCase().contains('already registered') ||
          err.toLowerCase().contains('already been registered') ||
          err.toLowerCase().contains('user already exists');

      if (isAlreadyRegistered) {
        setState(() => _emailError =
            'This email is already registered. Please login instead.');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Account Already Exists'),
            content: Text(
              'The email "${_emailCtrl.text.trim()}" is already registered.\n\nPlease log in with your password, or use a different email to create a new account.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        );
      } else if (err.toLowerCase().contains('password')) {
        setState(() => _passError = err);
      } else {
        Helpers.showSnack(
          context,
          err.isNotEmpty ? err : 'Registration failed. Please try again.',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            // ── Avatar Placeholder with '+' Badge ─────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCEDC8),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 52, color: Color(0xFF2E7D32)),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF43A047),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Green Banner Card: Join Grocery App ──────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join Grocery App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Fresh groceries delivered to you',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Form Inputs ──────────────────────────────────────
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Full Name
                  TextFormField(
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'Full Name',
                      icon: Icons.person_outline,
                      errorText: _nameError,
                    ),
                    validator: Validators.fullName,
                  ),
                  const SizedBox(height: 14),

                  // Email Address
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                      errorText: _emailError,
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      errorText: _passError,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 14),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: _inputDecoration(
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) => Validators.confirmPassword(v, _passCtrl.text),
                  ),
                  const SizedBox(height: 14),

                  // ── Password Requirements Checklist ─────────────
                  _buildRequirementRow('At least 6 characters', _hasMinLength),
                  const SizedBox(height: 6),
                  _buildRequirementRow('Must include a letter and a number', _hasLetterAndNumber),
                  const SizedBox(height: 24),

                  // ── Create Account Button ────────────────────────
                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                      ),
                      borderRadius: BorderRadius.circular(28),
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
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      onPressed: auth.loading ? null : _register,
                      child: auth.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Footer: Already have an account? Login ──────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
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

  Widget _buildRequirementRow(String text, bool fulfilled) {
    final color = fulfilled ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E);
    return Row(
      children: [
        Icon(
          fulfilled ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: fulfilled ? FontWeight.w600 : FontWeight.w400,
            color: color,
          ),
        ),
      ],
    );
  }
}
