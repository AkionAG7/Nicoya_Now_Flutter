import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class GetComidaRapida {
  final ProductsRepository repo;
  GetComidaRapida(this.repo);

  Future<List<Product>> call() async {
    return await repo.getComidaRapida();
  }
}
