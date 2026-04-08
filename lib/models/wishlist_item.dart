// lib/models/wishlist_item.dart
import 'product.dart';

class WishlistItem {
  final String  id;
  final String  userId;
  final Product product;
  final DateTime createdAt;

  const WishlistItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> j, Product product) =>
      WishlistItem(
        id:        j['id']        as String,
        userId:    j['user_id']   as String,
        product:   product,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}