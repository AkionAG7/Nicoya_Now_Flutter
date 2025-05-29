import 'package:nicoya_now/app/features/order/domain/entities/order.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderDatasource {
  Future<List<Map<String, dynamic>>> getOrderByUserId(String userId);
}

class OrderDatasourceImpl implements OrderDatasource {
  final SupabaseClient supabaseClient;
  OrderDatasourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getOrderByUserId(String userId) async {
    final response = await supabaseClient
        .from('order')
        .select('order_item(quantity, product:product_id(*))')
        .eq('customer_id', userId)
        .eq('status', 'pending');

    final List<Map<String, dynamic>> items = [];

    for (final order in response as List<dynamic>) {
      final itemList = order['order_item'] as List<dynamic>?;

      if (itemList != null) {
        for (final item in itemList) {
          final productJson = item['product'];
          final quantity = item['quantity'];

          if (productJson != null && quantity != null) {
            final product = Product.fromJson(productJson);
            items.add({'product': product, 'quantity': quantity});
          }
        }
      }
    }

    return items;
  }
}
