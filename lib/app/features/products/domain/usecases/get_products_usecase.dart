import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class GetAllProducts {
  final ProductsRepository repo;
  GetAllProducts(this.repo);

  Future<List<Product>> call() => repo.getAllProducts();
}
