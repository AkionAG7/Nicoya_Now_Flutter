import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';

class GetProductSearch{
  final ProductsRepository repo;
  GetProductSearch(this.repo);

  Future<List<Product>> call(String query) async{
    return await repo.getproductSearch(query);
  }
}