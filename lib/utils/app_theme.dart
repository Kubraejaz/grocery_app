// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand colours ──────────────────────────────────────────
  static const Color primary      = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF66BB6A);
  static const Color primaryDark  = Color(0xFF1B5E20);
  static const Color accent       = Color(0xFFF9A825);
  static const Color background   = Color(0xFFF4F6F8);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color textDark     = Color(0xFF1A1A2E);
  static const Color textMuted    = Color(0xFF6B7280);
  static const Color textLight    = Color(0xFF9CA3AF);
  static const Color success      = Color(0xFF16A34A);
  static const Color error        = Color(0xFFDC2626);
  static const Color warning      = Color(0xFFF59E0B);

  // ── Light theme ────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    colorScheme: const ColorScheme(
      brightness:      Brightness.light,
      primary:         primary,
      onPrimary:       Color(0xFFFFFFFF),
      secondary:       accent,
      onSecondary:     Color(0xFFFFFFFF),
      error:           error,
      onError:         Color(0xFFFFFFFF),
      surface:         surface,
      onSurface:       textDark,
    ),
    scaffoldBackgroundColor: background,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // // Cards
    // cardTheme: CardTheme(
    //   color: surface,
    //   elevation: 2,
    //   shadowColor: Colors.black.withOpacity(0.08),
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(16),
    //   ),
    // ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // TextFields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: textLight, fontSize: 14),
      labelStyle: const TextStyle(color: textMuted),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF3F4F6),
      thickness: 1,
      space: 1,
    ),
  );
}