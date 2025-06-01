import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_item_datasource.dart';
import 'package:nicoya_now/app/features/order/domain/repositories/order_item_repository.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class OrderItemsRespositoyImpl implements OrderItemRepository {
  final OrderItemDatasource datasource;
  OrderItemsRespositoyImpl({required this.datasource});

  @override
  Future<void> addProductToOrder(
    String customerId,
    Product product,
    int quantity,
    Address address,
  ) => datasource.addProductToOrder(customerId, product, quantity, address);

  @override
  Future<void> addProductToOrderWithAddressLookup({
    required String userId,
    required Product product,
    required int quantity,
  }) => datasource.addProductToOrderWithAddressLookup(
    userId: userId,
    product: product,
    quantity: quantity,
  );
}
