import 'package:nicoya_now/app/features/order/domain/entities/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getOrdersByMerchantId(String merchantId);
    Future<Order> getOrderById(String orderId);
}