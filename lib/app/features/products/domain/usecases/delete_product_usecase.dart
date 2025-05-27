import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class DeleteProductUseCase {
  final ProductsRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(String productId) {
    return repository.deleteProduct(productId);
  }
}
