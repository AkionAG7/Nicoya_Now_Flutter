import 'package:nicoya_now/app/features/order/domain/entities/order.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderDatasource {
  Future<List<Map<String, dynamic>>> getOrderByUserId(String userId);
  Future<List<Order>> getOrdersByMerchantId(String merchantId);
  Future<Order> getOrderById(String orderId);
  Future<void> confirmOrder(String userId);
  Future<void> removeProductFromOrder(String productId);
}

class OrderDatasourceImpl implements OrderDatasource {
  final SupabaseClient supabaseClient;
  OrderDatasourceImpl({required this.supabaseClient});
  @override
  Future<Order> getOrderById(String orderId) async {
    final resp =
        await supabaseClient
            .from('order')
            .select('''
      order_id,
      customer_id,
      merchant_id,
      delivery_address_id,
      total,
      placed_at,
      status
    ''')
            .eq('order_id', orderId)
            .maybeSingle();

    if (resp == null) {
      throw Exception('No se encontró la orden $orderId');
    }

    // Convertir el status string a enum
    final statusStr = resp['status'] as String? ?? 'pending';
    final OrderStatus orderStatus = OrderStatus.values.firstWhere(
      (e) => e.toString() == 'OrderStatus.$statusStr',
      orElse: () => OrderStatus.pending,
    );

    return Order(
      order_id: resp['order_id'],
      customer_id: resp['customer_id'],
      merchant_id: resp['merchant_id'],
      delivery_address_id: resp['delivery_address_id'],
      total: (resp['total'] as num).toDouble(),
      placed_at: DateTime.parse(resp['placed_at']),
      status: orderStatus,
    );
  }

  @override
  Future<List<Order>> getOrdersByMerchantId(String merchantId) async {
    // 1) Ejecuta la query con .execute()
    final response = await supabaseClient
        .from('order')
        .select('''
        order_id,
        customer_id,
        merchant_id,
        delivery_address_id,
        total,
        placed_at,
        status
      ''')
        .eq('merchant_id', merchantId)
        .order('placed_at', ascending: false);

    // No necesitamos otro await aquí, ya que response ya es el resultado
    final List<dynamic> rows = response;

    return rows.map((map) {
      // Convertir el status string a enum
      final statusStr = map['status'] as String? ?? 'pending';
      final OrderStatus orderStatus = OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.$statusStr',
        orElse: () => OrderStatus.pending,
      );

      return Order(
        order_id: map['order_id'],
        customer_id: map['customer_id'],
        merchant_id: map['merchant_id'],
        delivery_address_id: map['delivery_address_id'],
        total: (map['total'] as num).toDouble(),
        placed_at: DateTime.parse(map['placed_at']),
        status: orderStatus,
      );
    }).toList();
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

  @override
  Future<void> confirmOrder(String userId) async {
    print('Confirmando orden para userId: $userId');
    await supabaseClient
        .from('order')
        .update({'status': 'accepted'})
        .eq('customer_id', userId)
        .eq('status', 'pending');
  }

  Future<void> removeProductFromOrder(String orderItemId) async {
    // 1. Obtener el order_id del item a eliminar
    final orderItem =
        await supabaseClient
            .from('order_item')
            .select('order_id')
            .eq('order_item_id', orderItemId)
            .maybeSingle();

    if (orderItem == null) {
      throw Exception('No se encontró el producto a eliminar');
    }

    final String orderId = orderItem['order_id'];

    // 2. Eliminar el item
    await supabaseClient
        .from('order_item')
        .delete()
        .eq('order_item_id', orderItemId);

    // 3. Verificar si quedan más productos en esa orden
    final remainingItems = await supabaseClient
        .from('order_item')
        .select('order_item_id')
        .eq('order_id', orderId);

    if (remainingItems == null || remainingItems.isEmpty) {
      // 4. Si no quedan, eliminar la orden
      await supabaseClient.from('order').delete().eq('order_id', orderId);
    }
  }
}
