import 'package:nicoya_now/app/features/order/domain/entities/order.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderDatasource {
  Future<List<Map<String, dynamic>>> getOrderByUserId(String userId);
  Future<void> confirmOrder(String userId);
}

class OrderDatasourceImpl implements OrderDatasource {
  final SupabaseClient supabaseClient;
  OrderDatasourceImpl({required this.supabaseClient});

  @override
 Future<void> confirmOrder(String userId) async {
   print('Confirmando orden para userId: $userId');
  await supabaseClient
      .from('order')
      .update({'status': 'accepted'})
      .eq('customer_id', userId)
      .eq('status', 'pending'); 
}


  @override
  Future<List<Map<String, dynamic>>> getOrderByUserId(String userId) async {
    final response = await supabaseClient
        .from('order')
        .select('order_item(order_item_id, quantity, product:product_id(*))')
        .eq('customer_id', userId)
        .eq('status', 'pending');

    final List<Map<String, dynamic>> items = [];

    for (final order in response as List<dynamic>) {
      final itemList = order['order_item'] as List<dynamic>?;

      if (itemList != null) {
        for (final item in itemList) {
          final productJson = item['product'];
          final quantity = item['quantity'];
          final orderItemId = item['order_item_id'];

          if (productJson != null && quantity != null) {
            final product = Product.fromJson(productJson);
            items.add({
              'product': product,
              'quantity': quantity,
              'order_item_id': orderItemId,
            });
          }
        }
      }
    }

    return items;
  }
}
