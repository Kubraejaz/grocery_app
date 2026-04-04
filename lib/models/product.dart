// lib/models/product.dart

class Product {
  final String   id;
  final String   name;
  final String   description;
  final double   price;
  final double?  discountPrice;
  final String   imageUrl;
  final String   categoryId;
  final String   categoryName;
  final int      stock;
  final String   unit;          // kg | litre | piece | dozen
  final double   rating;
  final int      reviewCount;
  final bool     isFeatured;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.unit,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.createdAt,
  });

  // ── Computed helpers ──────────────────────────────────────
  bool   get isOnSale  => discountPrice != null && discountPrice! < price;
  bool   get isInStock => stock > 0;
  double get salePrice => discountPrice ?? price;
  double get discountPercent =>
      isOnSale ? ((price - discountPrice!) / price) * 100 : 0;

  // ── Factory ───────────────────────────────────────────────
  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id:           j['id']           as String,
        name:         j['name']         as String,
        description:  j['description']  as String? ?? '',
        price:        (j['price']       as num).toDouble(),
        discountPrice: j['discount_price'] != null
            ? (j['discount_price'] as num).toDouble()
            : null,
        imageUrl:     j['image_url']    as String? ?? '',
        categoryId:   j['category_id']  as String,
        categoryName: (j['categories']  as Map?)?['name'] as String? ?? '',
        stock:        j['stock']        as int?    ?? 0,
        unit:         j['unit']         as String? ?? 'piece',
        rating:       (j['rating']      as num?)?.toDouble() ?? 0.0,
        reviewCount:  j['review_count'] as int?    ?? 0,
        isFeatured:   j['is_featured']  as bool?   ?? false,
        createdAt:    DateTime.parse(
            j['created_at'] as String? ??
                DateTime.now().toIso8601String()),
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'name':         name,
        'description':  description,
        'price':        price,
        'discount_price': discountPrice,
        'image_url':    imageUrl,
        'category_id':  categoryId,
        'stock':        stock,
        'unit':         unit,
        'rating':       rating,
        'review_count': reviewCount,
        'is_featured':  isFeatured,
      };
}