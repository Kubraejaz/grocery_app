// lib/widgets/grocery_logo.dart
import 'package:flutter/material.dart';

class GroceryCartLogo extends StatelessWidget {
  final double size;
  const GroceryCartLogo({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow
          Container(
            width: size * 0.75,
            height: size * 0.75,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(size * 0.2),
            ),
          ),

          // Cart Graphics
          Padding(
            padding: EdgeInsets.all(size * 0.12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fresh veggies top
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size * 0.14,
                      height: size * 0.18,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: size * 0.14,
                      height: size * 0.22,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: size * 0.12,
                      height: size * 0.24,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: size * 0.14,
                      height: size * 0.20,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),

                // Green Shopping Cart body
                Container(
                  width: size * 0.52,
                  height: size * 0.26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(size * 0.08),
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.40,
                      height: size * 0.16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(size * 0.06),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),

                // Cart Wheels
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: size * 0.10,
                      height: size * 0.10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B5E20),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: size * 0.24),
                    Container(
                      width: size * 0.10,
                      height: size * 0.10,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B5E20),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

