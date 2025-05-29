import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/order/domain/repositories/order_item_repository.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class AddProductUsecase {
  final OrderItemRepository repo;
  AddProductUsecase(this.repo);

  Future<void> execute(
    String customerId,
    Product productId,
    int quantity,
    Address addressId,
  ) {
    return repo.addProductToOrder(customerId, productId, quantity, addressId);
  }
}
