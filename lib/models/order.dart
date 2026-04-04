// lib/models/order.dart

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class Order {
  final String      id;
  final String      userId;
  final double      totalAmount;
  final OrderStatus status;
  final String      deliveryAddress;
  final DateTime    createdAt;
  final List<Map<String, dynamic>> items;

  const Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id:              j['id']              as String,
        userId:          j['user_id']         as String,
        totalAmount:     (j['total_amount']   as num).toDouble(),
        status:          OrderStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => OrderStatus.pending,
        ),
        deliveryAddress: j['delivery_address'] as String? ?? '',
        createdAt:       DateTime.parse(j['created_at'] as String),
        items:           List<Map<String, dynamic>>.from(
            (j['order_items'] as List?) ?? []),
      );
}