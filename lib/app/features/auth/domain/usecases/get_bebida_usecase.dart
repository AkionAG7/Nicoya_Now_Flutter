import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/products_repository.dart';

class GetBebidas{
  final ProductsRepository repo;
  GetBebidas(this.repo);

  Future<List<Product>> call() async {
    return await repo.getBebida();
  }
}