// lib/utils/validators.dart
// All form validation rules in one place

class Validators {

  // ── Name ──────────────────────────────────────────────────
  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty)
      return 'Full name is required';
    if (v.trim().length < 3)
      return 'Name must be at least 3 characters';
    if (v.trim().length > 50)
      return 'Name must be less than 50 characters';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(v.trim()))
      return 'Name can only contain letters, spaces, hyphens';
    return null;
  }

  // ── Email ─────────────────────────────────────────────────
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty)
      return 'Email address is required';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim()))
      return 'Enter a valid email address (e.g. ali@gmail.com)';
    if (v.trim().length > 100)
      return 'Email is too long';
    return null;
  }

  // ── Password ──────────────────────────────────────────────
  static String? password(String? v) {
    if (v == null || v.isEmpty)
      return 'Password is required';
    if (v.length < 6)
      return 'Password must be at least 6 characters';
    if (v.length > 72)
      return 'Password must be less than 72 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(v))
      return 'Password must contain at least one letter';
    if (!RegExp(r'[0-9]').hasMatch(v))
      return 'Password must contain at least one number';
    return null;
  }

  // ── Confirm password ──────────────────────────────────────
  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty)
      return 'Please confirm your password';
    if (v != original)
      return 'Passwords do not match';
    return null;
  }

  // ── Phone (Pakistan format) ───────────────────────────────
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty)
      return 'Phone number is required';
    // Remove spaces, dashes, brackets for check
    final clean = v.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\d+$').hasMatch(clean))
      return 'Phone number must contain digits only';
    if (clean.length < 10)
      return 'Phone number must be at least 10 digits';
    if (clean.length > 15)
      return 'Phone number is too long';
    // Pakistan mobile: 03XXXXXXXXX or +923XXXXXXXXX
    if (!RegExp(r'^(03\d{9}|\+923\d{9}|3\d{9})$').hasMatch(clean))
      return 'Enter a valid Pakistani mobile number (03XX-XXXXXXX)';
    return null;
  }

  // ── Street address ────────────────────────────────────────
  static String? address(String? v) {
    if (v == null || v.trim().isEmpty)
      return 'Street address is required';
    if (v.trim().length < 10)
      return 'Please enter a complete address (min 10 characters)';
    if (v.trim().length > 200)
      return 'Address is too long';
    return null;
  }

  // ── City ──────────────────────────────────────────────────
  static String? city(String? v) {
    if (v == null || v.trim().isEmpty)
      return 'City is required';
    if (v.trim().length < 2)
      return 'Enter a valid city name';
    if (v.trim().length > 50)
      return 'City name is too long';
    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(v.trim()))
      return 'City name can only contain letters';
    return null;
  }

  // ── Required text (generic) ───────────────────────────────
  static String? required(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty)
      return '$fieldName is required';
    return null;
  }

  // ── Integer only ──────────────────────────────────────────
  static String? integerOnly(String? v, String fieldName,
      {int? min, int? max}) {
    if (v == null || v.trim().isEmpty)
      return '$fieldName is required';
    final n = int.tryParse(v.trim());
    if (n == null)
      return '$fieldName must be a whole number (no decimals or letters)';
    if (min != null && n < min)
      return '$fieldName must be at least $min';
    if (max != null && n > max)
      return '$fieldName must be at most $max';
    return null;
  }

  // ── Decimal/price ─────────────────────────────────────────
  static String? price(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty)
      return '$fieldName is required';
    final n = double.tryParse(v.trim());
    if (n == null)
      return '$fieldName must be a valid number';
    if (n < 0)
      return '$fieldName cannot be negative';
    if (n > 999999)
      return '$fieldName is unrealistically large';
    return null;
  }

  // ── Delivery note (optional but length-capped) ────────────
  static String? deliveryNote(String? v) {
    if (v == null || v.trim().isEmpty) return null; // optional
    if (v.trim().length > 300)
      return 'Note is too long (max 300 characters)';
    return null;
  }
}