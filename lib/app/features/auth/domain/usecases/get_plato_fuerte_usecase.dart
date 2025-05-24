import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/products_repository.dart';

class GetPlatoFuerte {
  final ProductsRepository repo;
  GetPlatoFuerte(this.repo);

  Future<List<Product>> call() async {
    return await repo.getPlatoFuerte();
  }
}
