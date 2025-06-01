import 'package:nicoya_now/app/features/order/data/datasources/order_item_datasource.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class AddProductToCart {
  final OrderItemDatasource datasource;

  AddProductToCart({required this.datasource});

  Future<void> call({
    required String userId,
    required Product product,
    required int quantity,
  }) async {
    await datasource.addProductToOrderWithAddressLookup(
      userId: userId,
      product: product,
      quantity: quantity,
    );
  }
}
