import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class OrderItemDatasource {
  Future<void> addProductToOrder(
    String merchant_id,
    Product poduct,
    int quantity,
    Address address,
  );
}

class OrderItemDatasourceImpl implements OrderItemDatasource {
  final SupabaseClient supa;
  OrderItemDatasourceImpl({required this.supa});

  @override
  Future<void> addProductToOrder(
    String customerId,
    Product product,
    int quantity,
    Address address,
  ) async {
    final subtotal = product.price * quantity;
    final existingOrder =
        await supa
            .from('order')
            .select()
            .eq('customer_id', customerId)
            .eq('status', 'pending')
            .maybeSingle();

    String orderId;

    if (existingOrder != null) {
      final existingMerchantId = existingOrder['merchant_id'];

      if (existingMerchantId != product.merchant_id) {
        throw Exception(
          'El producto no pertenece al mismo comerciante del pedido existente, finaliza primero tu orden actual.',
        );
      }
      orderId = existingOrder['order_id'];
      // Sumar el subtotal al total actual
      final double previousTotal = (existingOrder['total'] as num).toDouble();
      final newTotal = previousTotal + subtotal;

      await supa
          .from('order')
          .update({'total': newTotal})
          .eq('order_id', orderId);
    } else {
      final insertResult =
          await supa
              .from('order')
              .insert({
                'customer_id': customerId,
                'merchant_id': product.merchant_id,
                'delivery_address_id': address.address_id,
                'total': subtotal,
                'status': 'pending',
                'placed_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();
      orderId = insertResult['order_id'];
    }

    await supa.from('order_item').insert({
      'order_id': orderId,
      'product_id': product.product_id,
      'quantity': quantity,
      'unit_price': product.price,
    });
  }
}
