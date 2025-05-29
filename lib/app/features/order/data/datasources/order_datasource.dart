import 'package:nicoya_now/app/features/order/domain/entities/order.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderDatasource {
  Future<List<Product>> getOrderByUserId(String userId);
}

class OrderDatasourceImpl implements OrderDatasource {
  final SupabaseClient supabaseClient;
  OrderDatasourceImpl({required this.supabaseClient});

  @override
  Future<List<Product>> getOrderByUserId(String userId) async {
    final response = await supabaseClient
        .from('order')
        .select('order_item(product:product_id(*))')
        .eq('customer_id', userId)
        .eq('status', 'pending');

    final List<Product> products = [];

    for (final order in response as List<dynamic>) {
      final items = order['order_item'] as List<dynamic>?;

      if (items != null) {
        for (final item in items) {
          final productJson = item['product'];
          if (productJson != null) {
            try {
              final product = Product.fromJson(productJson);
              products.add(product);
            } catch (e) {
              print('Error al parsear producto: $e');
            }
          }
        }
      }
    }

    return products;
  }
}
