import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class GetPlatoFuerte {
  final ProductsRepository repo;
  GetPlatoFuerte(this.repo);

  Future<List<Product>> call() async {
    return await repo.getPlatoFuerte();
  }
}
