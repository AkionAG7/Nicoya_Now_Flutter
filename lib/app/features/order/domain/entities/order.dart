class Order {
  String order_id;
  String customer_id;
  String merchant_id;
  String delivery_address_id;
  double total;
  DateTime placed_at;
  OrderStatus status;

  Order({
    required this.order_id,
    required this.customer_id,
    required this.merchant_id,
    required this.delivery_address_id,
    required this.total,
    required this.placed_at,
    required this.status,
  });
}

enum OrderStatus { pending, accepted, in_process, on_way, delivered, cancelled }
