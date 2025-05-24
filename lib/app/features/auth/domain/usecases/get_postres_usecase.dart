import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/products_repository.dart';

class GetPostre{
  final ProductsRepository repo;
  GetPostre(this.repo);

  Future<List<Product>> call() async {
    return await repo.getPostre();
  }
}