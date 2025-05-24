import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/products_repository.dart';

class getComidaRapida {
  final ProductsRepository repo;
  getComidaRapida(this.repo);

  Future<List<Product>> call() async {
    return await repo.getComidaRapida();
  }
}
