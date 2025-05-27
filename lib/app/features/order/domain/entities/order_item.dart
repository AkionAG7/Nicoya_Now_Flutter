class OrderItem {
  String order_item_id;
  String order_id;
  String product_id;
  double unite_price;
  int quantity;

  OrderItem({
    required this.order_item_id,
    required this.order_id,
    required this.product_id,
    required this.unite_price,
    required this.quantity,
  });
}
