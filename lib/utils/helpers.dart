// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_theme.dart';

class Helpers {
  /// Format a price value → ₨ 1,250.00
  static String formatPrice(double price) =>
      '₨ ${NumberFormat('#,##0.00').format(price)}';

  /// Format DateTime → 24 Jan 2025
  static String formatDate(DateTime d) =>
      DateFormat('dd MMM yyyy').format(d);

  /// Capitalise first letter
  static String capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Show a floating SnackBar
  static void showSnack(
    BuildContext ctx,
    String msg, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(msg)),
            ],
          ),
          backgroundColor:
              error ? AppTheme.error : AppTheme.success,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}