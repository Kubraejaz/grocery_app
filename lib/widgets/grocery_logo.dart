// lib/widgets/grocery_logo.dart
import 'package:flutter/material.dart';

/// Official 3D Grocery App Logo loaded from high-res asset
class OfficialAppLogo extends StatelessWidget {
  final double size;
  final bool withShadow;

  const OfficialAppLogo({
    super.key,
    this.size = 100,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: withShadow
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => GroceryCartLogo(size: size),
        ),
      ),
    );
  }
}

class GroceryCartLogo extends StatelessWidget {
  final double size;
  const GroceryCartLogo({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _fallbackCart(size),
    );
  }

  Widget _fallbackCart(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(s * 0.24),
      ),
      child: Icon(Icons.shopping_cart_rounded, color: Colors.white, size: s * 0.55),
    );
  }
}

class GroceryBrandTitle extends StatelessWidget {
  final double fontSize;
  final bool showSmile;

  const GroceryBrandTitle({
    super.key,
    this.fontSize = 32,
    this.showSmile = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Grocery',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E5A22),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: fontSize * 0.35, color: const Color(0xFF43A047)),
                    const SizedBox(width: 2),
                    Text(
                      'App',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF388E3C),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (showSmile)
                  CustomPaint(
                    size: Size(fontSize * 1.1, fontSize * 0.25),
                    painter: _SmileCurvePainter(),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SmileCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(2, 4);
    path.quadraticBezierTo(size.width / 2, size.height + 4, size.width - 2, 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
