// lib/widgets/category_chip.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String       label;
  final bool         isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve:    Curves.easeInOut,
        margin:   const EdgeInsets.only(right: 10),
        padding:  const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color:        isSelected ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:      AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset:     const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      isSelected ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}