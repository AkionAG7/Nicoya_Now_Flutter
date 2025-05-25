class Product {
  final String product_id;
  final String merchant_id;
  final String name;
  final String description;
  final double price;
  final String? image_url;
  final bool is_activate;
  final DateTime created_at;
  final String category_id;

  Product({
    required this.product_id,
    required this.merchant_id,
    required this.name,
    required this.description,
    required this.price,
    this.image_url,
    this.is_activate = true,
    required this.created_at,
    required this.category_id,
  });
}
