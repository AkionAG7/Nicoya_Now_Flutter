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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product_id: json['product_id'] as String,
      merchant_id: json['merchant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      image_url: json['image_url'] as String?,
      is_activate: json['is_active'] as bool? ?? true,
      created_at: DateTime.parse(json['created_at'] as String),
      category_id: json['category_id'] as String,
    );
  }
}
