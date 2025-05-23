import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';

class Productmodel extends Product {
  Productmodel({
    required super.product_id,
    required super.merchant_id,
    required super.name,
    required super.description,
    required super.price,
    required super.image_url,
    required super.is_activate,
    required super.created_at,
    required super.category_id,
  });

  factory Productmodel.fromMap(Map<String, dynamic> map) {
    return Productmodel(
      product_id: map['product_id'],
      merchant_id: map['merchant_id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      image_url: map['image_url'],
      is_activate: map['is_activate'],
      created_at: DateTime.parse(map['created_at']),
      category_id: map['category_id'],
    );
  }
}
