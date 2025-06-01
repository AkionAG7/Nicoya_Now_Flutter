import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

abstract class OrderItemRepository {

  Future<void> addProductToOrder(
    String customerId,
    Product product,
    int quantity,
    Address address,
  );

  Future<void> addProductToOrderWithAddressLookup({
    required String userId,
    required Product product,
    required int quantity,
  });
}
