import 'package:nicoya_now/app/features/order/domain/entities/order.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderDatasource {
  Future<List<Map<String, dynamic>>> getOrderByUserId(String userId);
  Future<List<Order>> getOrdersByMerchantId(String merchantId);
  Future<Order> getOrderById(String orderId);
  Future<void> confirmOrder(String userId);
  Future<void> removeProductFromOrder(String productId);
  Future<void> updateOrderStatus(String orderId, String newStatus);
  Future<List<Map<String, dynamic>>> getCarritoActual();
  Future<void> updateOrderItems(List<Map<String, dynamic>> items);
}

class OrderDatasourceImpl implements OrderDatasource {
  final SupabaseClient supabaseClient;
  OrderDatasourceImpl({required this.supabaseClient});

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final resp = await supabaseClient
        .from('order')
        .update({'status': newStatus})
        .eq('order_id', orderId);

    if (resp == null || (resp is Map && resp['error'] != null)) {
      final errorMsg =
          resp is Map && resp['error'] != null
              ? resp['error']['message']
              : 'Unknown error';
      throw Exception('Error actualizando estado: $errorMsg');
    }
  }

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
    // ignore: avoid_print
    print('Confirmando orden para userId: $userId');
    await supabaseClient
        .from('order')
        .update({'status': 'accepted'})
        .eq('customer_id', userId)
        .eq('status', 'pending');
  }

  @override
  Future<void> removeProductFromOrder(String orderItemId) async {
    // 1. Obtener el item con datos completos para calcular el subtotal
    final orderItem =
        await supabaseClient
            .from('order_item')
            .select('order_id, quantity, unit_price')
            .eq('order_item_id', orderItemId)
            .maybeSingle();

    if (orderItem == null) {
      throw Exception('No se encontró el producto a eliminar');
    }

    final String orderId = orderItem['order_id'];
    final int quantity = orderItem['quantity'];
    final double unitPrice = (orderItem['unit_price'] as num).toDouble();
    final double subtotal = unitPrice * quantity;

    // 2. Obtener el total actual de la orden
    final order =
        await supabaseClient
            .from('order')
            .select('total')
            .eq('order_id', orderId)
            .maybeSingle();

    if (order != null) {
      final double previousTotal = (order['total'] as num).toDouble();
      final double updatedTotal = previousTotal - subtotal;

      // 3. Actualizar el total en la orden
      await supabaseClient
          .from('order')
          .update({'total': updatedTotal})
          .eq('order_id', orderId);
    }

    // 4. Eliminar el item
    await supabaseClient
        .from('order_item')
        .delete()
        .eq('order_item_id', orderItemId);

    // 5. Verificar si quedan más productos en esa orden
    final remainingItems = await supabaseClient
        .from('order_item')
        .select('order_item_id')
        .eq('order_id', orderId);

    if (remainingItems.isEmpty) {
      // 6. Si no quedan, eliminar la orden
      await supabaseClient.from('order').delete().eq('order_id', orderId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCarritoActual() async {
    final userId = supabaseClient.auth.currentUser?.id;

    if (userId == null) return [];

    return await getOrderByUserId(userId);
  }

  @override
  Future<void> updateOrderItems(List<Map<String, dynamic>> items) async {
    final Map<String, double> orderTotals = {};

    for (final item in items) {
      final orderItemId = item['order_item_id'];
      final quantity = item['quantity'];

      final updated =
          await supabaseClient
              .from('order_item')
              .update({'quantity': quantity})
              .eq('order_item_id', orderItemId)
              .select('order_id, unit_price')
              .single();

      final String orderId = updated['order_id'];
      final double unitPrice = (updated['unit_price'] as num).toDouble();
      final double subtotal = unitPrice * quantity;

      orderTotals[orderId] = (orderTotals[orderId] ?? 0) + subtotal;
    }

    for (final entry in orderTotals.entries) {
      await supabaseClient
          .from('order')
          .update({'total': entry.value})
          .eq('order_id', entry.key);
    }
  }
}
