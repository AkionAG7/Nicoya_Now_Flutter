import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ProductsDataSource {
  Future<List<Product>> fetchAllProducts();
}

class ProductsDataSourceImpl implements ProductsDataSource {
  final SupabaseClient supabaseClient;

  ProductsDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Product>> fetchAllProducts() async {
    final response = await supabaseClient.from('product').select();

    return (response as List).map((item) {
      try {
        return Product(
          product_id: item['product_id'] as String,
          merchant_id: item['merchant_id'] as String,
          name: item['name'] as String,
          description: item['description'] as String,
          price: item['price'] as double,
          image_url: item['image_url'] as String?,
          is_activate: item['is_active'] ?? true,
          created_at: DateTime.parse(item['created_at']),
          category_id: item['category_id'] as String,
        );
      } catch (e) {
       throw Exception('Se producio el siguiente error: $e');
      }
    }).toList();
  }
}
