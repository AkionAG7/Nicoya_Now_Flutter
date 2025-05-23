import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';

abstract class ProductsRepository {
  Future<List<Product>> getAllProducts();

}