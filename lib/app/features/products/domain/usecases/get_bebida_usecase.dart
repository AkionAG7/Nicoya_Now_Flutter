import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class GetBebidas{
  final ProductsRepository repo;
  GetBebidas(this.repo);

  Future<List<Product>> call() async {
    return await repo.getBebida();
  }
}