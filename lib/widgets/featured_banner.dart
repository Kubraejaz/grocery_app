// lib/widgets/featured_banner.dart
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';

class FeaturedBanner extends StatefulWidget {
  final List<Product> products;
  const FeaturedBanner({super.key, required this.products});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  late final PageController _pageCtrl;
  int    _currentPage = 0;
  Timer? _autoTimer;

  @override
  void initState() {
    super.initState();
    // viewportFraction: 1.0 — full width so swipe works perfectly
    _pageCtrl = PageController(viewportFraction: 1.0);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    if (widget.products.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % widget.products.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve:    Curves.easeInOut,
      );
    });
  }

  void _stopAutoSlide() => _autoTimer?.cancel();

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Banner slides ──────────────────────────────────
        SizedBox(
          height: 170,
          // Listener wraps PageView — detects drag start/end
          // so we pause auto-slide while user is swiping
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            // onHorizontalDrag* is intentionally NOT set here
            // so horizontal drags fall through to PageView.
            // We only pause auto-timer on any touch start.
            onPanDown:   (_) => _stopAutoSlide(),
            onPanCancel: ()  => _startAutoSlide(),
            onPanEnd:    (_) => _startAutoSlide(),
            child: PageView.builder(
              controller:    _pageCtrl,
              // physics: scroll on drag, snap to page
              physics:       const PageScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount:     widget.products.length,
              itemBuilder:   (context, idx) {
                final p = widget.products[idx];
                return Padding(
                  // Horizontal padding gives the "peek" effect
                  // without blocking swipe gestures
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    // onTap fires on a tap; horizontal swipe will NOT
                    // trigger onTap because PageView consumes the drag.
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailScreen(product: p),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin:  Alignment.centerLeft,
                          end:    Alignment.centerRight,
                          colors: [
                            AppTheme.primaryDark,
                            AppTheme.primary,
                            AppTheme.primaryLight,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:      AppTheme.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset:     const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Row(
                          children: [
                            // ── Text side ──────────────────
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    // Featured tag
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        '⭐  Featured',
                                        style: TextStyle(
                                          color:    Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Product name
                                    Text(
                                      p.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color:      Colors.white,
                                        fontSize:   17,
                                        fontWeight: FontWeight.bold,
                                        height:     1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Price
                                    Row(
                                      children: [
                                        Text(
                                          Helpers.formatPrice(
                                              p.salePrice),
                                          style: const TextStyle(
                                            color:      Colors.white,
                                            fontSize:   16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (p.isOnSale) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            Helpers.formatPrice(
                                                p.price),
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                              decoration: TextDecoration
                                                  .lineThrough,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Tap hint
                                    Row(
                                      children: const [
                                        Text(
                                          'View Details',
                                          style: TextStyle(
                                            color:      Colors.white70,
                                            fontSize:   12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white70,
                                          size:  14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ── Product image ───────────────
                            CachedNetworkImage(
                              imageUrl: p.imageUrl,
                              width:    130,
                              height:   170,
                              fit:      BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 130,
                                color:
                                    AppTheme.primaryLight.withOpacity(0.4),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color:       Colors.white54,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 130,
                                color:
                                    AppTheme.primaryLight.withOpacity(0.3),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.white54,
                                  size:  40,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // ── Dot indicators ─────────────────────────────────
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
            (i) => GestureDetector(
              behavior: HitTestBehavior.translucent,
              // Tap a dot to jump to that slide
              onTap: () => _pageCtrl.animateToPage(
                i,
                duration: const Duration(milliseconds: 400),
                curve:    Curves.easeInOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:   const EdgeInsets.symmetric(horizontal: 3),
                width:    _currentPage == i ? 24 : 7,
                height:   7,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? AppTheme.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}