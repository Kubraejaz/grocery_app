// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _addrCtrl  = TextEditingController();
  final _cityCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl  = TextEditingController();
  final _orderSvc  = OrderService();

  bool _placing = false;
  int  _paymentMethod = 0; // 0 = Cash on Delivery, 1 = Card

  @override
  void dispose() {
    _addrCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final cart    = context.read<CartProvider>();
    final address =
        '${_addrCtrl.text.trim()}, ${_cityCtrl.text.trim()} | '
        'Phone: ${_phoneCtrl.text.trim()}'
        '${_noteCtrl.text.trim().isNotEmpty ? ' | Note: ${_noteCtrl.text.trim()}' : ''}';

    try {
      final orderId = await _orderSvc.placeOrder(
        items:   cart.items,
        total:   cart.totalAmount,
        address: address,
      );
      await cart.clear();
      if (!mounted) return;
      _showSuccess(orderId);
    } catch (e) {
      if (!mounted) return;
      Helpers.showSnack(context, 'Failed to place order: $e', error: true);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _showSuccess(String orderId) {
    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width:  90,
              height: 90,
              decoration: BoxDecoration(
                color:  AppTheme.success.withOpacity(0.1),
                shape:  BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.success,
                size:  52,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Order Placed! 🎉',
              style: TextStyle(
                fontSize:   22,
                fontWeight: FontWeight.bold,
                color:      AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Order #${orderId.substring(0, 8).toUpperCase()}',
              style: const TextStyle(
                color:   AppTheme.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your order has been placed successfully!\n'
              'We will deliver it to you soon.',
              textAlign: TextAlign.center,
              style:     TextStyle(
                color:  AppTheme.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (_) => false,
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label, IconData icon, {String? hint}) =>
      InputDecoration(
        labelText:  label,
        hintText:   hint,
        prefixIcon: Icon(icon),
      );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Delivery details ───────────────────────
              _SectionHeader(
                icon:  Icons.location_on_outlined,
                title: 'Delivery Details',
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _addrCtrl,
                maxLines:   2,
                decoration: _dec(
                    'Street Address', Icons.home_outlined,
                    hint: 'House #, Street, Area'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your address'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller:   _cityCtrl,
                decoration:   _dec(
                    'City', Icons.location_city_outlined,
                    hint: 'e.g. Karachi, Lahore, Islamabad'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Please enter your city'
                    : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller:   _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration:   _dec(
                    'Phone Number', Icons.phone_outlined,
                    hint: '03XX-XXXXXXX'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Please enter phone number';
                  if (v.trim().length < 10)
                    return 'Enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _noteCtrl,
                maxLines:   2,
                decoration: _dec(
                    'Delivery Note (optional)',
                    Icons.note_outlined,
                    hint: 'e.g. Ring the bell, leave at door…'),
              ),

              const SizedBox(height: 24),

              // ── Payment method ─────────────────────────
              _SectionHeader(
                icon:  Icons.payment_outlined,
                title: 'Payment Method',
              ),
              const SizedBox(height: 14),

              _PaymentOption(
                index:     0,
                selected:  _paymentMethod,
                icon:      Icons.money_outlined,
                label:     'Cash on Delivery',
                subtitle:  'Pay when your order arrives',
                onTap:     () => setState(() => _paymentMethod = 0),
              ),
              const SizedBox(height: 10),
              _PaymentOption(
                index:     1,
                selected:  _paymentMethod,
                icon:      Icons.credit_card_outlined,
                label:     'Credit / Debit Card',
                subtitle:  'Visa, Mastercard, EasyPaisa',
                onTap:     () => setState(() => _paymentMethod = 1),
              ),

              const SizedBox(height: 24),

              // ── Order summary ──────────────────────────
              _SectionHeader(
                icon:  Icons.receipt_long_outlined,
                title: 'Order Summary',
              ),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  children: [
                    ...cart.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name}  ×${item.quantity}',
                                style: const TextStyle(
                                  color:   AppTheme.textMuted,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              Helpers.formatPrice(item.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:   13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   16,
                            ),
                          ),
                          Text(
                            Helpers.formatPrice(cart.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:   18,
                              color:      AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _placing ? null : _placeOrder,
                child:     _placing
                    ? const SizedBox(
                        height: 22,
                        width:  22,
                        child:  CircularProgressIndicator(
                          color:       Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Place Order'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                fontSize:   17,
                fontWeight: FontWeight.bold,
                color:      AppTheme.textDark,
              )),
        ],
      );
}

class _PaymentOption extends StatelessWidget {
  final int   index;
  final int   selected;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.index,
    required this.selected,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:        isSelected
              ? AppTheme.primary.withOpacity(0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppTheme.primary : AppTheme.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.textDark,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}