import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class GetPostre{
  final ProductsRepository repo;
  GetPostre(this.repo);

  Future<List<Product>> call() async {
    return await repo.getPostre();
  }
}