// lib/models/cart_item.dart
import 'product.dart';

class CartItem {
  final String  id;
  final String  userId;
  final Product product;
  int           quantity;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.quantity,
  });

  // ── Computed ──────────────────────────────────────────────
  double get subtotal => product.salePrice * quantity;

  // ── Factory ───────────────────────────────────────────────
  factory CartItem.fromJson(Map<String, dynamic> j, Product product) =>
      CartItem(
        id:       j['id']       as String,
        userId:   j['user_id']  as String,
        product:  product,
        quantity: j['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'user_id':    userId,
        'product_id': product.id,
        'quantity':   quantity,
      };
}