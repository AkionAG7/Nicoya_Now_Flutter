import '../entities/products.dart';
import '../repositories/products_repository.dart';

class AddProductUseCase {
  final ProductsRepository repository;

  AddProductUseCase(this.repository);

  Future<void> execute(Product product) {
    return repository.addProduct(product);
  }
}
