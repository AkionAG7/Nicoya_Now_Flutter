import '../repositories/products_repository.dart';
import '../entities/products.dart';

class UpdateProductUseCase {
  final ProductsRepository repository;

  UpdateProductUseCase(this.repository);

  Future<void> call(Product product) async {
    await repository.updateProduct(product);
  }
}
