import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';

abstract class ProductsRepository {
  Future<List<Product>> getAllProducts();
  Future<List<Product>> getPostre();
  Future<List<Product>> getPlatoFuerte();
  Future<List<Product>> getBebida();
  Future<List<Product>> getComidaRapida();
}