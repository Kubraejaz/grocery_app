// lib/widgets/featured_banner.dart
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
  final _pageCtrl = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Slides ─────────────────────────────────────────
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller:    _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount:     widget.products.length,
            itemBuilder:   (_, idx) {
              final p = widget.products[idx];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: p),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
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
                        color:      AppTheme.primary.withOpacity(0.35),
                        blurRadius: 14,
                        offset:     const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Text side
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment:  MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color:        Colors.white24,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  '⭐ Featured',
                                  style: TextStyle(
                                    color:   Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                p.name,
                                maxLines:  2,
                                overflow:  TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color:      Colors.white,
                                  fontSize:   17,
                                  fontWeight: FontWeight.bold,
                                  height:     1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    Helpers.formatPrice(p.salePrice),
                                    style: const TextStyle(
                                      color:      Colors.white,
                                      fontSize:   16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (p.isOnSale) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      Helpers.formatPrice(p.price),
                                      style: const TextStyle(
                                        color:      Colors.white60,
                                        fontSize:   12,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Image side
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight:    Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: p.imageUrl,
                          width:    130,
                          height:   170,
                          fit:      BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width:  130,
                            color:  AppTheme.primaryLight.withOpacity(0.4),
                            child:  const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white54, strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 130,
                            color: AppTheme.primaryLight.withOpacity(0.3),
                            child: const Icon(Icons.image_outlined,
                                color: Colors.white54, size: 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Dot indicators ─────────────────────────────────
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin:   const EdgeInsets.symmetric(horizontal: 3),
              width:    _currentPage == i ? 22 : 7,
              height:   7,
              decoration: BoxDecoration(
                color:        _currentPage == i
                    ? AppTheme.primary
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}